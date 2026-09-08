#!/bin/bash
# Configure DigiPi for Tigertronics SignaLink USB + Kenwood TM-D700 DATA port.
# Run on the Raspberry Pi AFTER DigiPi Initialize (radio interface: USB Audio, GPIO12).
# DigiPi is read-only until remounted.
set -euo pipefail

CALLSIGN_DEFAULT=""
PLAYBACK_PERCENT="${PLAYBACK_PERCENT:-80}"
CAPTURE_PERCENT="${CAPTURE_PERCENT:-70}"

red() { printf '\033[1;31m%s\033[0m\n' "$*"; }
grn() { printf '\033[1;32m%s\033[0m\n' "$*"; }
ylw() { printf '\033[1;33m%s\033[0m\n' "$*"; }
inf() { printf '%s\n' "$*"; }

need_root() {
  if [[ "${EUID}" -ne 0 ]]; then
    red "Re-run as root:  sudo $0"
    exit 1
  fi
}

remount_rw() {
  if command -v remount >/dev/null 2>&1; then
    remount || true
  fi
  if ! mount -o remount,rw / 2>/dev/null; then
    ylw "Could not remount /. If commands fail, run: sudo remount"
  else
    grn "Root filesystem remounted read-write."
  fi
  if [[ -d /boot ]]; then
    mount -o remount,rw /boot 2>/dev/null || true
  fi
  if [[ -d /boot/firmware ]]; then
    mount -o remount,rw /boot/firmware 2>/dev/null || true
  fi
}

print_hardware_cheatsheet() {
  cat <<'EOF'

=== Kenwood TM-D700 + SignaLink USB ===

Cable: SLCAB6PM into the radio DATA jack (6-pin mini-DIN on the radio body).
Jumper module: SLMOD6PM
  or JP1 wires: MIC->pin1  GND->pin2  PTT->pin3  SPK->pin5 (1200 baud)

Radio:
  - Internal TNC OFF
  - Built-in APRS OFF
  - Menu 1-9-6 DATA SPEED = 1200 bps
  - Radio VOX OFF
  - Packet follows the TX band (not menu 1-6-1)
  - Start at 5 W; US APRS 144.390 FM (EU 144.800)

SignaLink knobs: TX ~9-10 o'clock, RX ~12 o'clock, DLY fully CCW.

DigiPi Initialize radio interface: USB Audio, GPIO12
  (SignaLink keys via VOX; GPIO12 is unused.)

EOF
}

find_signalink_card() {
  local line card name
  SIGNALINK_CARD=""
  SIGNALINK_ID=""

  if [[ ! -r /proc/asound/cards ]]; then
    red "No ALSA cards found."
    return 1
  fi

  while IFS= read -r line; do
    # /proc/asound/cards:  1 [CODEC          ]: USB-Audio - USB Audio CODEC
    if [[ "${line}" =~ ^[[:space:]]*([0-9]+)[[:space:]]+\[([^]]+)\] ]]; then
      card="${BASH_REMATCH[1]}"
      id="$(echo "${BASH_REMATCH[2]}" | sed 's/[[:space:]]*$//')"
      if echo "${line}" | grep -qiE 'USB Audio|USB-Audio|CODEC|C-Media'; then
        if echo "${line}" | grep -qiE 'bcm2835|vc4hdmi|Headphones|fe-pi|AudioInjector'; then
          continue
        fi
        SIGNALINK_CARD="${card}"
        SIGNALINK_ID="${id}"
        inf "Detected USB audio card ${SIGNALINK_CARD}: ${line}"
        return 0
      fi
    fi
  done < /proc/asound/cards

  red "SignaLink USB Audio CODEC not found."
  inf "Plug the SignaLink into a Pi USB port (not a passive hub) and re-run."
  inf "Current cards:"
  cat /proc/asound/cards || true
  lsusb 2>/dev/null || true
  return 1
}

write_asoundrc() {
  local user_home="/home/pi"
  local card="${SIGNALINK_CARD}"
  local id="${SIGNALINK_ID:-CODEC}"

  cat > "${user_home}/.asoundrc" <<EOF
# Written by configure-signalink-d700.sh
# SignaLink USB Audio CODEC as default device.
pcm.!default {
    type plug
    slave.pcm "plughw:${card},0"
}
ctl.!default {
    type hw
    card ${card}
}
EOF
  chown pi:pi "${user_home}/.asoundrc" 2>/dev/null || true

  if [[ -f /usr/share/alsa/alsa.conf ]]; then
    if grep -qE 'defaults\.(ctl|pcm)\.card' /usr/share/alsa/alsa.conf; then
      sed -i.bak-signalink \
        -e "s/^defaults.ctl.card[[:space:]].*/defaults.ctl.card ${card}/" \
        -e "s/^defaults.pcm.card[[:space:]].*/defaults.pcm.card ${card}/" \
        /usr/share/alsa/alsa.conf
    fi
  fi

  grn "ALSA default card set to ${card} (${id})."
}

set_mixer_levels() {
  local card="${SIGNALINK_CARD}"
  local ctl
  inf "Setting mixer on card ${card}: playback ${PLAYBACK_PERCENT}%, capture ${CAPTURE_PERCENT}%."

  for ctl in Speaker PCM Master Playback; do
    if amixer -c "${card}" sget "${ctl}" >/dev/null 2>&1; then
      amixer -c "${card}" -q sset "${ctl}" "${PLAYBACK_PERCENT}%" unmute || true
    fi
  done

  for ctl in Mic 'Mic Capture' Capture 'Line' 'Mic Boost'; do
    if amixer -c "${card}" sget "${ctl}" >/dev/null 2>&1; then
      amixer -c "${card}" -q sset "${ctl}" "${CAPTURE_PERCENT}%" unmute || true
      amixer -c "${card}" -q sset "${ctl}" cap 2>/dev/null || true
    fi
  done

  # Auto-gain on cheap USB codecs often wrecks packet audio.
  amixer -c "${card}" -q sset 'Auto Gain Control' off 2>/dev/null || true
  amixer -c "${card}" -q sset AGC off 2>/dev/null || true

  if command -v alsactl >/dev/null 2>&1; then
    alsactl store || true
  fi
}

patch_direwolf_file() {
  local file="$1"
  local card="${SIGNALINK_CARD}"
  local tmp

  [[ -f "${file}" ]] || return 0
  cp -a "${file}" "${file}.bak-signalink"

  tmp="$(mktemp)"
  awk -v card="${card}" '
    BEGIN { adevice=0 }
    /^[[:space:]]*ADEVICE[[:space:]]/ {
      print "ADEVICE plughw:" card ",0  plughw:" card ",0"
      adevice=1
      next
    }
    /^[[:space:]]*#?ADEVICE[[:space:]]/ && adevice==0 {
      print "ADEVICE plughw:" card ",0  plughw:" card ",0"
      adevice=1
      next
    }
    { print }
    END {
      if (adevice==0) {
        print ""
        print "# SignaLink USB (configure-signalink-d700.sh)"
        print "ADEVICE plughw:" card ",0  plughw:" card ",0"
      }
    }
  ' "${file}" > "${tmp}"
  mv "${tmp}" "${file}"

  # SignaLink VOX keys PTT. Leave a GPIO12 line if DigiPi already has one;
  # it is harmless with nothing wired. Document VOX in a comment.
  if ! grep -q 'SignaLink USB uses VOX' "${file}"; then
    printf '\n# SignaLink USB uses VOX PTT. Keep DLY fully CCW. GPIO12 unused.\n' >> "${file}"
  fi

  inf "Updated ${file}"
}

patch_direwolf() {
  local f
  for f in \
    /home/pi/direwolf.conf \
    /home/pi/direwolf.tnc.conf \
    /home/pi/direwolf.digipeater.conf \
    /home/pi/direwolf.igate.conf \
    /home/pi/direwolf.winlink.conf \
    /home/pi/direwolf.tnc300b.conf
  do
    patch_direwolf_file "${f}"
  done
}

write_notes() {
  cat > /home/pi/SIGNALINK-D700.txt <<'EOF'
SignaLink USB + Kenwood TM-D700 on DigiPi
==========================================

Initialize radio interface: USB Audio, GPIO12

After level changes:
  sudo remount
  alsamixer          # F6 = USB Audio CODEC, F3 playback, F4 capture
  sudo alsactl store

Direwolf RX target: average audio around 50 (PktLog 10-90).

D700: TNC off, APRS off, menu 1-9-6 = 1200, radio VOX off.
SignaLink: DLY fully counterclockwise.
EOF
  chown pi:pi /home/pi/SIGNALINK-D700.txt 2>/dev/null || true
}

verify() {
  inf ""
  inf "--- verification ---"
  inf "USB devices:"
  lsusb 2>/dev/null || true
  inf ""
  inf "ALSA cards:"
  cat /proc/asound/cards
  inf ""
  if command -v arecord >/dev/null 2>&1; then
    inf "Capture devices:"
    arecord -l || true
  fi
  grn "Configuration written. Reboot DigiPi from the web UI."
}

main() {
  need_root
  print_hardware_cheatsheet
  remount_rw
  find_signalink_card
  write_asoundrc
  set_mixer_levels
  patch_direwolf
  write_notes
  verify
}

main "$@"
