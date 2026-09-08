#!/usr/bin/env bash
# Host-side DigiPi flasher for Linux/macOS.
# Target: Raspberry Pi 3B+ + SignaLink USB + Kenwood TM-D700.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
PI_SCRIPT="${ROOT}/scripts/configure-signalink-d700.sh"
IMAGE="${IMAGE:-}"
DEVICE="${DEVICE:-}"

usage() {
  cat <<'EOF'
Usage: sudo ./install-digipi.sh [--image FILE] [--device /dev/sdX|/dev/diskN]

Flashes a DigiPi image you already downloaded from https://digipi.org
(Patreon). Does not fetch or redistribute that image.

After flash, copies configure-signalink-d700.sh to the boot partition.
On the Pi, after Initialize (USB Audio, GPIO12):

  sudo remount
  sudo bash /boot/configure-signalink-d700.sh
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --image) IMAGE="$2"; shift 2 ;;
    --device) DEVICE="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1"; usage; exit 1 ;;
  esac
done

if [[ "${EUID}" -ne 0 ]]; then
  echo "Re-run as root so the SD card can be written: sudo $0 $*"
  exit 1
fi

find_image() {
  if [[ -n "${IMAGE}" && -f "${IMAGE}" ]]; then
    echo "${IMAGE}"
    return
  fi
  local f
  f="$(ls -1t "${ROOT}"/digipi*.img "${ROOT}"/digipi*.zip "${ROOT}"/digipi*.img.xz 2>/dev/null | head -n1 || true)"
  if [[ -z "${f}" ]]; then
    echo "Place a DigiPi .img/.zip in ${ROOT} or pass --image" >&2
    exit 1
  fi
  echo "${f}"
}

unpack_image() {
  local src="$1"
  case "${src}" in
    *.img) echo "${src}" ;;
    *.zip)
      mkdir -p "${ROOT}/work"
      unzip -o "${src}" -d "${ROOT}/work" >/dev/null
      ls -1t "${ROOT}"/work/*.img | head -n1
      ;;
    *.xz)
      mkdir -p "${ROOT}/work"
      local dest="${ROOT}/work/$(basename "${src}" .xz)"
      xz -dkf -T0 "${src}"
      echo "${dest}"
      ;;
    *) echo "Unsupported image: ${src}" >&2; exit 1 ;;
  esac
}

list_disks() {
  echo "Block devices:"
  lsblk -o NAME,SIZE,TYPE,TRAN,MODEL,MOUNTPOINT 2>/dev/null || diskutil list
}

img_src="$(find_image)"
img="$(unpack_image "${img_src}")"
echo "Image: ${img}"
list_disks

if [[ -z "${DEVICE}" ]]; then
  read -r -p "Device to ERASE (e.g. /dev/sdb or /dev/disk2): " DEVICE
fi

if [[ ! -b "${DEVICE}" && ! -e "${DEVICE}" ]]; then
  echo "Not a block device: ${DEVICE}" >&2
  exit 1
fi

echo "ABOUT TO ERASE ${DEVICE}"
read -r -p "Type ERASE to continue: " confirm
[[ "${confirm}" == "ERASE" ]] || { echo "Aborted."; exit 1; }

echo "Writing..."
dd if="${img}" of="${DEVICE}" bs=4M status=progress conv=fsync
sync

# Mount boot and copy helper
sleep 2
BOOT_MNT="${ROOT}/work/boot-mnt"
mkdir -p "${BOOT_MNT}"
BOOT_PART=""
if [[ "${DEVICE}" == /dev/mmcblk* || "${DEVICE}" == /dev/nvme* ]]; then
  BOOT_PART="${DEVICE}p1"
elif [[ "${DEVICE}" == /dev/disk* ]]; then
  BOOT_PART="${DEVICE}s1"
else
  BOOT_PART="${DEVICE}1"
fi

if [[ -e "${BOOT_PART}" ]]; then
  mount "${BOOT_PART}" "${BOOT_MNT}" || true
  if [[ -f "${BOOT_MNT}/config.txt" || -f "${BOOT_MNT}/cmdline.txt" ]]; then
    cp "${PI_SCRIPT}" "${BOOT_MNT}/configure-signalink-d700.sh"
    cat > "${BOOT_MNT}/RUN-ON-PI.txt" <<'EOF'
After Initialize (USB Audio, GPIO12):
  sudo remount
  sudo bash /boot/configure-signalink-d700.sh
EOF
    echo "Copied helper to boot partition."
  fi
  umount "${BOOT_MNT}" 2>/dev/null || true
fi

echo
echo "Next: boot the Pi 3B+, join Wi-Fi DigiPi / abcdefghij, http://10.0.0.5/"
echo "Initialize radio interface = USB Audio, GPIO12"
echo "Then run configure-signalink-d700.sh on the Pi."
echo "See PROCEDURE.md."
