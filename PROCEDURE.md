# DigiPi on Raspberry Pi 3B+ with SignaLink USB and Kenwood TM-D700

This procedure installs [DigiPi](https://digipi.org) (KM6LYW) on a **Raspberry Pi 3B+** and interfaces it to a **Kenwood TM-D700 / TM-D700A** through a **Tigertronics SignaLink USB**.

DigiPi is a ready-made Raspberry Pi image. You do not compile it. You flash it, initialize it, then apply SignaLink audio settings.

The helper scripts in this folder automate the SD-card flash and the on-Pi SignaLink configuration. They do **not** download the DigiPi image. That image is distributed to [KM6LYW Patreon](https://www.patreon.com/km6lyw) supporters.

---

## 1. Parts

| Item | Notes |
| --- | --- |
| Raspberry Pi 3B+ | Supported. Avoid original Pi Zero / Pi 2 / 3A (single-core). |
| Official 5 V / 2.5 A+ PSU | Undervoltage drops USB audio and causes decode errors. |
| microSD card | 8 GB or larger, Class 10 / A1. |
| SignaLink USB | USB audio + VOX PTT. |
| Cable **SLCAB6PM** (or combo **SLUSB6PM**) | 6-pin mini-DIN to the D700 **DATA** jack. |
| Jumper module **SLMOD6PM** | Or four jumper wires (see below). |
| Kenwood TM-D700 / TM-D700A | DATA jack is a 6-pin mini-DIN on the **radio body**, not the mic. |
| DigiPi image | Current line: **v2.2-1** (Sept 2026). Download from Patreon, do not redistribute. |

Do **not** use the D700 microphone jack for this setup. Use the DATA port.

---

## 2. SignaLink jumpers (TM-D700 DATA port)

Easiest path: plug in **SLMOD6PM**. That module is listed for TM-D700 / TM-D700A.

If you are wiring JP1 yourself (1200 baud APRS / packet):

```
SignaLink JP1          D700 DATA pin     Signal
------------------------------------------------
MIC  ----------------> Pin 1            PKD  (TX audio in)
GND  ----------------> Pin 2            Ground
PTT  ----------------> Pin 3            PKS  (PTT)
SPK  ----------------> Pin 5            PR1  (1200 baud RX audio)
```

Leave pin 4 and pin 6 unjumpered for 1200 baud.

| D700 DATA pin | Name | Use |
| --- | --- | --- |
| 1 | PKD | Packet TX audio into the radio |
| 2 | GND | Ground |
| 3 | PKS | PTT (SignaLink grounds this to key TX) |
| 4 | PR9 | 9600 baud discriminator audio |
| 5 | PR1 | 1200 baud RX audio (use this for APRS) |
| 6 | SQC | Squelch output (not used by SignaLink) |

For VARA FM Wide / 9600-style audio only: move **SPK** from pin 5 to **pin 4**, and set radio menu **1-9-6** to 9600. Default for DigiPi APRS is **1200**.

### SignaLink front-panel knobs

| Knob | Starting point |
| --- | --- |
| **TX** | About 9–10 o’clock. Raise until the radio shows RF, then back off until the signal is clean (not overdriven). |
| **RX** | About 12 o’clock. Fine-tune from DigiPi **Audio** / Direwolf levels. |
| **DLY** | Fully counterclockwise (minimum). SignaLink VOX must drop PTT quickly after tones stop. |

The D700 radio **VOX must be OFF**. SignaLink provides its own VOX.

---

## 3. Kenwood TM-D700 radio setup

Power the radio off while plugging the 6-pin DATA cable.

1. Turn the radio on.
2. Press **TNC** until the built-in TNC is **off** (TNC icon gone). DigiPi/Direwolf is the TNC.
3. Turn **APRS** off on the radio so the built-in tracker does not fight Direwolf.
4. Menu **1-9-6 DATA SPEED** → **1200 bps**.
5. Menu **1-6-1 DATA BAND** is only for the **internal** TNC. With SignaLink, packet follows the **TX band**. Select the band you will use and set that VFO/memory to the packet frequency.
6. Radio VOX: **OFF**.
7. CTCSS / DCS: **OFF** on the packet channel (APRS is simplex).
8. Start at **low power** (5 W) until levels are confirmed.

US APRS: **144.390 MHz** FM. Europe: **144.800 MHz** FM.

---

## 4. Flash DigiPi (Windows)

### Option A — helper script (recommended)

1. Put the DigiPi `.zip` or `.img` in this folder, or pass `-Image`.
2. Insert a blank microSD (USB reader).
3. Right-click `install-digipi.bat` → **Run as administrator**.

The script lists removable disks, flashes the image, and copies `configure-signalink-d700.sh` onto the DigiPi boot partition.

### Option B — Raspberry Pi Imager / Balena Etcher

1. Unzip the DigiPi download if the tool requires a `.img`.
2. Flash the image to the microSD. An 8 GB card is enough.
3. After flash, copy `scripts/configure-signalink-d700.sh` onto the FAT **boot** partition.

Official flash notes: [digipi.org](https://digipi.org).

---

## 5. First boot and Wi-Fi

1. Insert the card in the Pi 3B+. Plug in the SignaLink USB. Apply power.
2. Wait for the **DigiPi** Wi-Fi hotspot.
3. Join it. Password: `abcdefghij`
4. Browse to **http://10.0.0.5/** → **Wifi**.
5. Enter home SSID and password. Reboot.
6. On your LAN, open **http://digipi/** or **http://digipi.local/**.
   - If DNS fails, use the Pi’s DHCP address from the router.
   - If the hotspot is still up, home Wi-Fi did not take. Recheck SSID/password.

Default SSH user: `pi` / `raspberry`.

---

## 6. Initialize DigiPi for SignaLink

On http://digipi/ click **Initialize**.

| Field | Value for this station |
| --- | --- |
| Callsign / passwords / grid | Yours. Initialize once; later edits go in `/home/pi/localize.env`. |
| Radio interface | **USB Audio, GPIO12** |

SignaLink is USB audio with **internal VOX**. There is no CAT PTT. KM6LYW’s guidance is to pick **USB Audio, GPIO12**. GPIO12 is unused; SignaLink keys the D700 when it hears TX audio.

Click **Initialize**, then **Reboot**. The Pi returns to read-only “firmware” mode.

---

## 7. On-Pi SignaLink configuration

SSH in, or use the DigiPi **Shell** page. On current DigiPi (Bookworm, v2.x) the FAT boot partition is mounted at **`/boot/firmware`**, not `/boot`.

```bash
sudo remount
ls -l /boot/firmware/configure-signalink-d700.sh /boot/configure-signalink-d700.sh
sudo bash /boot/firmware/configure-signalink-d700.sh
```

`configure-signalink-d700.sh: command not found` means bash never found a path. Always use `sudo bash` and the full path. The helper is not a DigiPi built-in and is not on `PATH`.

If `ls` finds nothing, the Windows/Linux flasher did not copy the helper (for example you used Raspberry Pi Imager alone). From this PC:

```powershell
scp scripts\configure-signalink-d700.sh pi@10.0.0.5:~/
```

Then on the Pi: `sudo remount && chmod +x ~/configure-signalink-d700.sh && sudo bash ~/configure-signalink-d700.sh`.

The script:

- remounts the DigiPi filesystem read-write
- finds the SignaLink **USB Audio CODEC**
- makes it the default ALSA device
- raises playback (TX) so SignaLink VOX keys
- sets capture (RX) to a sane start point
- points Direwolf `ADEVICE` at the USB card
- saves mixer state

Then reboot from the DigiPi home page.

---

## 8. Audio levels

On http://digipi/ open **Audio**:

- Playback / Speaker → TX into SignaLink (often 70–90%). Too low = no PTT. Too high = dirty FM.
- Capture (press F4 in alsamixer) → RX. Direwolf **PktLog** average should land near **50** (range 10–90).

If the SignaLink PTT LED never lights: raise Pi playback **and** the SignaLink **TX** knob.

---

## 9. Verify

1. D700 on 144.390 (or local APRS), squelch just closed, low power.
2. SignaLink USB LED on; RX LED flickers with local packets.
3. DigiPi home page: start **APRS IGate** or **Digipeater**.
4. **PktLog** should decode other stations.
5. Send a test from **APRS WebChat**. SignaLink PTT LED and D700 TX should key, then drop quickly (DLY at minimum).
6. Check [aprs.fi](https://aprs.fi) for your call.

---

## 10. Defaults and useful URLs

| Item | Value |
| --- | --- |
| Hotspot SSID / password | `DigiPi` / `abcdefghij` |
| Hotspot URL | http://10.0.0.5/ |
| LAN URL | http://digipi/ or http://digipi.local/ |
| SSH | `pi` / `raspberry` |
| VNC | `digipi:5901` password `test11` |
| Make filesystem writable | `sudo remount` |
| After-init edits | `/home/pi/localize.env` |

Community: [DigiPi Google Group](https://groups.google.com/g/digipi) · [Discord](https://discord.gg/3X9bMjjwxw)

---

## 11. Troubleshooting

| Symptom | Likely cause |
| --- | --- |
| No USB sound card | SignaLink unplugged, cheap hub, or weak PSU. Use a Pi USB port directly. |
| RX LED idle, no decodes | SPK jumper not on pin 5; radio on wrong band; volume too low; internal TNC still on. |
| TX audio, radio never keys | DLY/TX too low; Pi Speaker muted; jumpers missing PTT pin 3. |
| Radio keys but no RF / no path | TX audio too low or too high; radio not on TX band; frequency/CTCSS. |
| Radio stays keyed | SignaLink **DLY** not at minimum. |
| Hotspot never appears | Bad flash, wrong Pi model, or insufficient power. |
| Init already used | Edit `/home/pi/localize.env` after `sudo remount`. |
| `configure-signalink-d700.sh: command not found` | Missing path. Use `sudo bash /boot/firmware/configure-signalink-d700.sh`. |
| LinPac / APRS call is missing a letter | Initialize truncated it. See §14. |
| Reboot takes ~1 minute | Normal. See §15. |

---

## 12. Dashboard switches

The home page toggles are **service on/off**, not a settings form. Callsign, grid, and radio interface come from **Initialize**. Each flip starts or stops a systemd unit and reloads the page.

| Square | Meaning |
| --- | --- |
| Grey | Off |
| Green | Running |
| Red | Failed — open **SysLog** / **PktLog** |

**One radio modem at a time.** Starting APRS TNC stops digipeater, node, Winlink RMS, FT8, FLDigi, and the rest. Direwolf cannot share the SignaLink with two stacks.

| Switch | What it starts | Use on this station |
| --- | --- | --- |
| **APRS TNC/igate** | 1200-baud Direwolf + APRS-IS (`YOURCALL-2`) | VHF APRS / WebChat / LinPac modem |
| **APRS HF TNC/igate** | 300-baud HF packet | Leave **off** (D700 is VHF FM) |
| **APRS Digipeater** | 1200-baud Direwolf that also repeats RF (`WIDE1-1`) | Do not run with TNC/igate. Details: [APRS-DIGIPEATER.md](APRS-DIGIPEATER.md) |
| **APRS GPS Tracker** | Mobile GPS beacon | Needs a GPS receiver |
| **APRS WebChat** | APRS messaging app | Turn TNC/igate **on first**, then this, then the **Webchat** link |
| **AX.25 Node Network** | Linux node/BBS (`YOURCALL-4`) | Then **AXCall** or LinPac |
| **AX.25 linBPQ** | G8BPQ linBPQ node/BBS (`YOURCALL-7`) | Install first (§16). Not with Node |
| **Winlink Email Server** | RMS gateway (`YOURCALL-10`) | Not at the same time as Node |
| **Pat Winlink Client** | Your Winlink mailbox | Then **PatEmail** |
| **WSJTX / JS8Call / FLDigi / SSTV** | GUI apps over VNC/web | Poor fit for the D700 DATA jack |

**LinPac is not a switch.** Start **APRS TNC/igate** (or Node), then **AXCall** → LinPac.

**linBPQ** is a switch under AX.25 after you run `install-linbpq.sh`. It runs its own Direwolf (not the APRS igate) and is exclusive with Node, TNC, and Winlink RMS.

Bottom links (**Webchat**, **PktLog**, **Audio**, **AXCall**, **Shell**, …) only work after the matching switch is green.

Switches **do not survive reboot**. Stock `digipi-boot.service` starts nothing but the “Online” banner. To auto-start IGate:

```bash
sudo remount
sudo nano /etc/systemd/system/digipi-boot.service
```

Uncomment **one** `ExecStart=systemctl start …` line (for example `tnc`). Leave the others commented.

**Save Configuration** does **not** store switch positions. It copies the RAM overlay (audio, fldigi/wsjtx, LinPac files, logs) back to the SD card. Press it after **Audio** or app edits, then **Restart** or **Shutdown**.

---

## 13. APRS TNC / IGate

**TNC** = Direwolf as a software modem on SignaLink USB audio. The D700 stays analog FM; its built-in TNC stays **off**.

**IGate** = those decoded packets are uploaded to APRS-IS. Your login is `YOURCALL-2`. A `PBEACON sendto=IG` puts the igate on [aprs.fi](https://aprs.fi) without beaconing that position on RF.

```
144.390 FM → D700 DATA → SignaLink USB → Direwolf
                 RF decode ──► APRS-IS (YOURCALL-2)
                 WebChat / KISS ──► SignaLink VOX ──► D700 TX
```

TNC/igate does **not** digipeat `WIDE1-1`. That is **APRS Digipeater** — full write-up and home-page links: **[APRS-DIGIPEATER.md](APRS-DIGIPEATER.md)**. Digipeater internet → RF is limited (nearby messages); the whole APRS-IS feed is not dumped onto 144.390.

1. D700 on **144.390 FM** (US), internal TNC off, SignaLink **DLY** fully CCW.
2. Dashboard: **APRS TNC/igate** ON.
3. **PktLog** — other stations decode; audio average near **50**.
4. **APRS WebChat** ON → **Webchat** to send a message or beacon.
5. Check `YOURCALL-2` on aprs.fi.

Decodes but no map: radio path is fine, APRS-IS login is not. No decodes: audio, jumpers, frequency, or the radio TNC still on.

Full write-up — switch, **home-page links**, which half to blame, config paths: **[APRS-TNC-IGATE.md](APRS-TNC-IGATE.md)**.

---

## 14. LinPac on DigiPi

Do **not** install a second Direwolf/LinPac stack on this image. DigiPi already includes LinPac.

1. Hardware and `configure-signalink-d700.sh` as above.
2. Tune the D700 to local **packet simplex** (often 145.010 / 145.050), not APRS 144.390, unless you intend to chat on APRS.
3. Dashboard: **APRS TNC/igate** ON (1200-baud modem). For HF 300 baud only, use **APRS HF TNC**.
4. Open **AXCall** / LinPac (browser terminal runs `/home/pi/linpac.sh`). If no TNC is up, that script starts 1200-baud TNC and attaches AX.25 port `radio`.

Initialize writes your callsign into `/home/pi/config/LinPac/macro/init.mac` (runtime copy is `/home/pi/.config/LinPac`, often under `/run`). Confirm:

```bash
grep -E 'mycall|unsrc|port |HOME_BBS|QRG' /home/pi/config/LinPac/macro/init.mac
```

You want `port radio`, `mycall@1 YOURCALL` (no SSID), `unsrc YOURCALL`. DigiPi SSIDs: LinPac = no SSID, TNC/igate = `-2`, node = `-4`, linBPQ = `-7`, Winlink = `-10`.

If the callsign is truncated (for example `kc4jr` instead of `kc4jir`), Initialize dropped a character. After `sudo remount`, fix every live config — at minimum:

```bash
sudo sed -i -E 's/\bBADCALL\b/GOODCALL/g' \
  /home/pi/config/LinPac/macro/init.mac \
  /home/pi/.config/LinPac/macro/init.mac \
  /home/pi/direwolf.tnc.conf \
  /etc/ax25/axports
```

Replace `BADCALL` / `GOODCALL` with the truncated and full call. Then `sudo chown pi:pi /home/pi/direwolf.tnc.conf` (`sudo sed` can leave the file `root:600`, which prevents Direwolf from copying it to `/run`). Restart **APRS TNC/igate**.

Fresh images keep Craig’s old LinPac screen logs. Clear them:

```bash
sudo remount
truncate -s 0 /home/pi/config/LinPac/window1.screen \
  /home/pi/config/LinPac/monitor.screen \
  /home/pi/.config/LinPac/window1.screen \
  /home/pi/.config/LinPac/monitor.screen
```

Then **Save Configuration**.

LinPac commands start with `:`. Anything else is sent to the connected station.

| Key / command | Action |
| --- | --- |
| F1–F8 | QSO channels |
| F10 | Unproto / CQ |
| PageUp / PageDown | Scrollback |
| `:c OTHERCALL` | Connect |
| `:d` | Disconnect |
| Alt+X | Quit |

Quick TNC test without LinPac: `axcall radio OTHERCALL`.

---

## 15. Why restart takes about a minute

A Pi 3B+ DigiPi reboot of ~**1 minute 18 seconds** is normal. Measured userspace:

| Service | Wait | Why |
| --- | --- | --- |
| `autohotspot.service` | ~35 s | Hard-coded `sleep 30`, then hotspot if home Wi-Fi is missing |
| `rc-local.service` | ~19 s | Splash, copy overlay into `/run`, another `sleep 10` |
| `digipi-boot.service` | ~10 s | Another `sleep 10`, then Online/Hotspot banner |
| NetworkManager | ~12 s | Associate and wait-online |

The image is read-only. Each boot copies LinPac, fldigi, VNC, and related trees into RAM under `/run`. If you land on hotspot **http://10.0.0.5/**, you paid the full autohotspot wait.

---

## 16. Add linBPQ to DigiPi

Stock DigiPi has Linux **AX.25 Node Network** (uronode). G8BPQ **linBPQ** is not on the image. `scripts/install-linbpq.sh` installs it and adds an **AX.25 linBPQ** switch under that AX.25 group.

linBPQ runs its **own** Direwolf (KISS on port 8001). It is not the APRS igate. It cannot share the SignaLink with Node, TNC, or DigiPi Winlink RMS.

### Before you start

1. Finish **Initialize** (callsign, grid, node password, Winlink password).
2. Run `configure-signalink-d700.sh` (§7). Radio interface **USB Audio, GPIO12**.
3. D700: internal TNC **off**, APRS **off**, menu **1-9-6 = 1200**, radio VOX **off**. SignaLink **DLY** fully CCW.
4. For Winlink CMS (`RMS`), the Pi needs **home Wi-Fi / internet**. The DigiPi hotspot alone cannot reach Winlink.

The Windows/Linux flashers copy `install-linbpq.sh` onto the boot partition when that file is in this repo.

### Install

On the Pi:

```bash
sudo remount
sudo bash /boot/firmware/install-linbpq.sh
```

On older images the helper is `/boot/install-linbpq.sh`. If it is not on the boot partition, copy `scripts/install-linbpq.sh` from this repo to the Pi (Shell upload, `scp`, or `/home/pi/`), then:

```bash
sudo remount
chmod +x ~/install-linbpq.sh
sudo bash ~/install-linbpq.sh
```

Refresh **http://digipi/** (or **http://10.0.0.5/**). **AX.25 linBPQ** should sit directly under **AX.25 Node Network**.

The installer writes `/home/pi/linbpq/` (binary, `bpq32.cfg`, HTML), a `linbpq.service` unit, a dedicated `direwolf.linbpq.sh`, and the home-page switch. Callsign and passwords come from `/home/pi/localize.env`.

### Run it

1. Tune the D700 to local **packet simplex** (often 145.010 / 145.030), not APRS 144.390.
2. Leave **AX.25 Node Network**, **APRS TNC/igate**, and DigiPi **Winlink Email Server** **off**.
3. Flip **AX.25 linBPQ** on (green).
4. Open the **linBPQ** link at the bottom of the home page, or **http://digipi:8008/**.
5. Sign in: user **`sysop`**, password = DigiPi node password (Initialize; default `abc123`). This is not the Linux `pi` login.
6. After BBS/Chat/RMS use, click **Save Configuration** so `/run/linbpq` is copied to `/home/pi/linbpq` on the SD card.

### Node commands and SSIDs

| Command | Application | AX.25 call | Needs |
| --- | --- | --- | --- |
| (connect to node) | Switch | **YOURCALL-7** | linBPQ running |
| `BBS` | Mail BBS | **YOURCALL-1** | `LINMAIL` in `bpq32.cfg` |
| `CHAT` | Chat | **YOURCALL-11** | `LINCHAT` and `chatconfig.cfg` (`ApplNum=2`) |
| `RMS` | Winlink CMS | **YOURCALL-10** | `CMS=1`, `CMSCALL`, `CMSPASS` (Initialize Winlink password) |

Linux **AX.25 Node Network** stays **YOURCALL-4** if you use that switch instead. APRS igate stays **YOURCALL-2**.

linBPQ ports:

| Port | What it is | Connect |
| --- | --- | --- |
| **1** | Telnet / HTTP / CMS (internet) | Web console, `RMS` |
| **2** | Direwolf → SignaLink → D700 (radio) | `c 2 OTHERCALL` or `c OTHERCALL` |

Do **not** use `c 1` for an RF station. That is the telnet port.

### Winlink email (`RMS`)

With Initialize’s Winlink password present, the installer (or `enable-linbpq-winlink.sh`) sets `CMS=1` and `APPLICATION 3,RMS,C 1 CMS,YOURCALL-10`. Leave DigiPi **Winlink Email Server** off; linBPQ `RMS` is the Winlink path while linBPQ is on.

1. Pi on home Wi-Fi.
2. linBPQ web **Terminal** → type `RMS`.
3. You should see a CMS connect and a `[WL2K-…]` banner. Type `B` to leave CMS.
4. Over radio, a Winlink client can connect to **YOURCALL-10**.

If CMS is unreachable, linBPQ falls back to the local BBS (`FALLBACKTORELAY` / `RELAYAPPL=BBS`).

Already installed without RMS? Copy `scripts/enable-linbpq-winlink.sh` to the Pi:

```bash
sudo remount
sudo bash ~/enable-linbpq-winlink.sh
```

### BBS and Chat not running

`APPLICATION` lines only name the commands. The servers start only if `bpq32.cfg` has **`LINMAIL`** and **`LINCHAT`**. The installer writes those plus `chatconfig.cfg`. On an older install:

```bash
sudo remount
sudo bash ~/enable-linbpq-mail-chat.sh
```

Then **Save Configuration**. At the node prompt, type `BBS` or `CHAT` (not `c 1`).

### Edit configuration

Canonical file: `/home/pi/linbpq/bpq32.cfg`. Runtime copy is `/run/linbpq/` (RAM).

1. `sudo remount`
2. **Stop** linBPQ first (`AX.25 linBPQ` off). Stop rsyncs `/run/linbpq` → `/home/pi/linbpq`; if you edit home while it is running, stop can overwrite your edit.
3. Edit `/home/pi/linbpq/bpq32.cfg`.
4. Start linBPQ (switch on). Start rsyncs home → `/run`.

To keep an existing `bpq32.cfg` when re-running the installer: `sudo LINBPQ_KEEP_CFG=1 bash /boot/firmware/install-linbpq.sh`. That still adds missing `LINMAIL` / `LINCHAT` / CMS lines.

### Troubleshooting

| Symptom | What to check |
| --- | --- |
| No **AX.25 linBPQ** switch | Installer did not patch `/var/www/html/index.php`. Re-run `install-linbpq.sh`, hard-refresh the home page. |
| Switch red / fails | **SysLog**. Another radio app still up. `sudo systemctl reset-failed linbpq` then flip the switch. |
| `sysop` login rejected | Node password from Initialize (`NEWNODEPASS`), default `abc123`. Not `pi` / `raspberry`. |
| `Sorry, Application BBS/CHAT is not running` | Missing `LINMAIL` / `LINCHAT`. Run `enable-linbpq-mail-chat.sh`. |
| `RMS` does not reach CMS | No internet (hotspot-only), or no Winlink password in Initialize. Run `enable-linbpq-winlink.sh`. |
| `c 1 OTHERCALL` then Invalid Command | Port 1 is telnet. Use `c 2 OTHERCALL` on packet simplex. |

---

## License note

DigiPi is a collective-work image from KM6LYW Radio. These helper scripts do not include that image. Share the scripts; do not post the DigiPi image online.
