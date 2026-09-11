#requires -Version 5.1
<#
.SYNOPSIS
  Flash a DigiPi image to microSD and stage the SignaLink / TM-D700 helper.

.DESCRIPTION
  DigiPi itself is a Patreon image (https://digipi.org). This script does not
  download it. Place the .zip or .img next to this script, or pass -Image.

  Target hardware: Raspberry Pi 3B+ + SignaLink USB + Kenwood TM-D700 DATA port.

.PARAMETER Image
  Path to digipi-*.img or .zip.

.PARAMETER DiskNumber
  Windows disk number from Get-Disk (NOT a partition letter).

.PARAMETER SkipFlash
  Only copy configure-signalink-d700.sh to an already-flashed boot partition.

.PARAMETER ShowProcedure
  Print the install procedure and exit.
#>
[CmdletBinding()]
param(
    [string]$Image,
    [int]$DiskNumber = -1,
    [switch]$SkipFlash,
    [switch]$ShowProcedure
)

$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$PiScript = Join-Path $Root 'scripts\configure-signalink-d700.sh'
$Procedure = Join-Path $Root 'PROCEDURE.md'

function Write-Step([string]$Message) {
    Write-Host "`n==> $Message" -ForegroundColor Cyan
}

function Write-Warn([string]$Message) {
    Write-Host $Message -ForegroundColor Yellow
}

function Write-Ok([string]$Message) {
    Write-Host $Message -ForegroundColor Green
}

function Show-ProcedureText {
    if (Test-Path $Procedure) {
        Get-Content -LiteralPath $Procedure -Raw | Write-Host
    } else {
        Write-Host @"
DigiPi + SignaLink + Kenwood TM-D700 (Pi 3B+)

1. Get the DigiPi image from KM6LYW Patreon (do not redistribute).
2. SignaLink: SLMOD6PM + SLCAB6PM into D700 DATA jack.
   Jumpers 1200 baud: MIC=1 GND=2 PTT=3 SPK=5. DLY fully CCW.
3. Radio: TNC off, APRS off, menu 1-9-6 = 1200, VOX off.
4. Flash SD (this script or Raspberry Pi Imager).
5. Boot Pi, join Wi-Fi 'DigiPi' / abcdefghij, open http://10.0.0.5/
6. Set home Wi-Fi, reboot, open http://digipi/
7. Initialize: radio interface = USB Audio, GPIO12. Reboot.
8. sudo remount && sudo bash /boot/firmware/configure-signalink-d700.sh
"@
    }
}

if ($ShowProcedure) {
    Show-ProcedureText
    exit 0
}

function Assert-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p = New-Object Security.Principal.WindowsPrincipal($id)
    if (-not $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "Run this script as Administrator (needed to write a physical disk)."
    }
}

function Find-Image {
    param([string]$Hint)
    if ($Hint -and (Test-Path -LiteralPath $Hint)) {
        return (Resolve-Path -LiteralPath $Hint).Path
    }
    $candidates = Get-ChildItem -LiteralPath $Root -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -match '(?i)digipi.*\.(img|zip|xz)$' } |
        Sort-Object LastWriteTime -Descending
    if ($candidates) {
        return $candidates[0].FullName
    }
    return $null
}

function Expand-DigiPiImage {
    param([string]$Path)
    $ext = [IO.Path]::GetExtension($Path).ToLowerInvariant()
    if ($ext -eq '.img') { return $Path }

    $outDir = Join-Path $Root 'work'
    New-Item -ItemType Directory -Force -Path $outDir | Out-Null

    if ($ext -eq '.zip') {
        Write-Step "Unzipping $(Split-Path $Path -Leaf)"
        Expand-Archive -LiteralPath $Path -DestinationPath $outDir -Force
        $img = Get-ChildItem -LiteralPath $outDir -Recurse -Filter '*.img' |
            Sort-Object Length -Descending |
            Select-Object -First 1
        if (-not $img) { throw "No .img found inside $Path" }
        return $img.FullName
    }

    if ($ext -eq '.xz') {
        $xz = Get-Command xz -ErrorAction SilentlyContinue
        if (-not $xz) {
            throw "Install xz (Git for Windows or chocolatey xz) to decompress .xz images, or unzip to .img first."
        }
        $dest = Join-Path $outDir ([IO.Path]::GetFileNameWithoutExtension($Path))
        Write-Step "Decompressing xz"
        & xz -dkf -T0 $Path
        if (-not (Test-Path $dest)) {
            $sibling = [IO.Path]::ChangeExtension($Path, '.img')
            if (Test-Path $sibling) { return $sibling }
        }
        return $dest
    }

    throw "Unsupported image type: $Path"
}

function Get-RemovableDisks {
    Get-Disk | Where-Object {
        $_.BusType -in @('USB', 'SD', 'FileBackedVirtual') -or
        $_.FriendlyName -match '(?i)SD|Card Reader|Card$|USB'
    }
}

function Show-Disks {
    Write-Step "Removable / USB disks"
    Get-RemovableDisks | Format-Table Number, FriendlyName, BusType,
        @{n = 'SizeGB'; e = { [math]::Round($_.Size / 1GB, 2) } }, PartitionStyle -AutoSize | Out-String | Write-Host
    Get-Disk | Format-Table Number, FriendlyName, BusType,
        @{n = 'SizeGB'; e = { [math]::Round($_.Size / 1GB, 2) } }, PartitionStyle -AutoSize | Out-String | Write-Host
}

function Find-RpiImager {
    $paths = @(
        "$env:ProgramFiles\Raspberry Pi Imager\rpi-imager.exe",
        "${env:ProgramFiles(x86)}\Raspberry Pi Imager\rpi-imager.exe",
        "$env:LocalAppData\Programs\Raspberry Pi Imager\rpi-imager.exe"
    )
    foreach ($p in $paths) {
        if (Test-Path $p) { return $p }
    }
    $cmd = Get-Command rpi-imager -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    return $null
}

function Write-ImageToDisk {
    param(
        [string]$Img,
        [int]$Number
    )
    $disk = Get-Disk -Number $Number
    $sizeGb = [math]::Round($disk.Size / 1GB, 2)
    Write-Warn "ABOUT TO ERASE disk $Number ($($disk.FriendlyName), ${sizeGb} GB)."
    Write-Warn "This destroys all data on that disk. System disks are never a valid target."
    $confirm = Read-Host "Type ERASE to flash DigiPi to disk $Number"
    if ($confirm -ne 'ERASE') {
        throw "Aborted. You did not type ERASE."
    }

    $imager = Find-RpiImager
    if ($imager) {
        Write-Step "Flashing with Raspberry Pi Imager CLI"
        $physical = "\\.\PhysicalDrive$Number"
        & $imager --cli $Img $physical
        if ($LASTEXITCODE -ne 0) {
            throw "rpi-imager exited with code $LASTEXITCODE"
        }
        return
    }

    Write-Warn "Raspberry Pi Imager not found. Using raw disk copy (slow)."
    Write-Warn "Install https://www.raspberrypi.com/software/ for a better flasher."

    $disk | Set-Disk -IsOffline $true -ErrorAction SilentlyContinue
    try {
        $outPath = "\\.\PhysicalDrive$Number"
        $bufferSize = 4MB
        $inStream = [IO.File]::OpenRead($Img)
        $outStream = New-Object IO.FileStream($outPath, [IO.FileMode]::Open, [IO.FileAccess]::Write, [IO.FileShare]::None)
        try {
            $buffer = New-Object byte[] $bufferSize
            $copied = [long]0
            $total = $inStream.Length
            while (($read = $inStream.Read($buffer, 0, $buffer.Length)) -gt 0) {
                $outStream.Write($buffer, 0, $read)
                $copied += $read
                if (($copied % (64MB)) -lt $bufferSize) {
                    $pct = [math]::Round(100.0 * $copied / $total, 1)
                    Write-Progress -Activity "Writing DigiPi image" -Status "$pct% ($([math]::Round($copied/1MB)) MB)" -PercentComplete $pct
                }
            }
            $outStream.Flush()
        } finally {
            $outStream.Dispose()
            $inStream.Dispose()
            Write-Progress -Activity "Writing DigiPi image" -Completed
        }
    } finally {
        $disk | Set-Disk -IsOffline $false -ErrorAction SilentlyContinue
    }
}

function Copy-HelperToBoot {
    if (-not (Test-Path $PiScript)) {
        Write-Warn "Missing $PiScript — skip boot-partition copy."
        return
    }

    Write-Step "Waiting for DigiPi boot partition"
    $deadline = (Get-Date).AddMinutes(2)
    $boot = $null
    while ((Get-Date) -lt $deadline) {
        $vols = Get-Volume -ErrorAction SilentlyContinue | Where-Object {
            $_.DriveLetter -and (
                $_.FileSystemLabel -match '(?i)boot|digipi' -or
                $_.FileSystem -eq 'FAT32'
            )
        }
        foreach ($v in $vols) {
            $letter = "$($v.DriveLetter):\"
            # DigiPi / Raspberry Pi boot has config.txt or cmdline.txt
            if ((Test-Path (Join-Path $letter 'config.txt')) -or
                (Test-Path (Join-Path $letter 'cmdline.txt'))) {
                $boot = $letter
                break
            }
        }
        if ($boot) { break }
        Start-Sleep -Seconds 2
    }

    if (-not $boot) {
        Write-Warn "Boot partition not found automatically."
        Write-Warn "Copy scripts\configure-signalink-d700.sh onto the FAT boot volume yourself."
        return
    }

    Copy-Item -LiteralPath $PiScript -Destination (Join-Path $boot 'configure-signalink-d700.sh') -Force
    $readme = Join-Path $boot 'RUN-ON-PI.txt'
    @"
DigiPi SignaLink + Kenwood TM-D700 helper
=========================================

After Initialize (radio interface = USB Audio, GPIO12):

  sudo remount
  sudo cp /boot/configure-signalink-d700.sh /home/pi/
  # if not found:
  sudo cp /boot/firmware/configure-signalink-d700.sh /home/pi/
  chmod +x /home/pi/configure-signalink-d700.sh
  sudo /home/pi/configure-signalink-d700.sh

Then Reboot from http://digipi/

Hotspot: DigiPi / abcdefghij   URL: http://10.0.0.5/
"@ | Set-Content -LiteralPath $readme -Encoding ASCII
    Write-Ok "Copied configure-signalink-d700.sh to $boot"
}

# --- main ---
Write-Host "DigiPi installer for Pi 3B+ / SignaLink USB / Kenwood TM-D700" -ForegroundColor Cyan
Write-Host "Full write-up: $Procedure"
Write-Host "Print it with:  powershell -File install-digipi.ps1 -ShowProcedure"
Write-Host "Image source: https://digipi.org  (Patreon password; do not post the image online)"

if (-not $SkipFlash) {
    Assert-Admin
}

$imgIn = Find-Image -Hint $Image
if (-not $SkipFlash) {
    if (-not $imgIn) {
        Write-Warn "No DigiPi .img/.zip found in $Root"
        $imgIn = Read-Host "Path to DigiPi image (.img or .zip)"
    }
    if (-not (Test-Path -LiteralPath $imgIn)) {
        throw "Image not found: $imgIn"
    }
    $imgFile = Expand-DigiPiImage -Path (Resolve-Path $imgIn).Path
    Write-Ok "Using image $imgFile"

    Show-Disks
    if ($DiskNumber -lt 0) {
        $DiskNumber = [int](Read-Host "Disk number to ERASE and flash")
    }
    $sys = Get-Disk | Where-Object { $_.IsSystem -or $_.IsBoot }
    if ($sys.Number -contains $DiskNumber) {
        throw "Disk $DiskNumber is a system/boot disk. Refusing to flash."
    }
    Write-ImageToDisk -Img $imgFile -Number $DiskNumber
    Write-Ok "Flash complete."
}

Copy-HelperToBoot

Write-Step "Next hardware / software steps"
Write-Host @"
1. Insert the microSD in the Pi 3B+. Plug SignaLink into a Pi USB port.
2. DATA cable: SignaLink -> D700 6-pin DATA jack. Knobs: DLY fully CCW.
3. Radio: TNC off, APRS off, menu 1-9-6 = 1200, VOX off, TX band = APRS freq.
4. Power the Pi. Join Wi-Fi 'DigiPi' password abcdefghij.
5. http://10.0.0.5/  -> Wifi -> home SSID -> reboot.
6. http://digipi/ -> Initialize -> radio interface USB Audio, GPIO12.
7. After reboot: sudo remount && sudo bash /boot/firmware/configure-signalink-d700.sh
8. Check PktLog (~50) and SignaLink PTT LED on a test APRS frame.

See PROCEDURE.md for pinout, menus, and troubleshooting.
"@
Write-Ok "Done."
