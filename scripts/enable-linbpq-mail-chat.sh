#!/bin/bash
# One-shot: start linBPQ BBS (LINMAIL) and Chat (LINCHAT).
# Run on the Pi: sudo bash enable-linbpq-mail-chat.sh
set -euo pipefail

LINBPQ_DIR="/home/pi/linbpq"
CFG="${LINBPQ_DIR}/bpq32.cfg"

if [[ "${EUID}" -ne 0 ]]; then
  echo "Re-run as root: sudo $0" >&2
  exit 1
fi

if command -v remount >/dev/null 2>&1; then
  remount || true
fi
mount -o remount,rw / 2>/dev/null || true

CALL="KC4JIR"
GRID="EM82EN"
if [[ -f /home/pi/localize.env ]]; then
  # shellcheck disable=SC1091
  source /home/pi/localize.env
  CALL="$(echo "${NEWCALL:-${CALL}}" | tr '[:lower:]' '[:upper:]')"
  GRID="$(echo "${NEWGRID:-${GRID}}" | tr '[:lower:]' '[:upper:]')"
fi
CALL="${CALL%%-*}"

systemctl stop linbpq

[[ -f "${CFG}" ]] || { echo "Missing ${CFG}" >&2; exit 1; }

if ! grep -q '^LINMAIL' "${CFG}"; then
  printf '\nLINMAIL\n' >> "${CFG}"
fi
if ! grep -q '^LINCHAT' "${CFG}"; then
  printf 'LINCHAT\n' >> "${CFG}"
fi

cat > "${LINBPQ_DIR}/chatconfig.cfg" <<EOF
Chat :
{
  ApplNum = 2;
  MaxStreams = 10;
  chatPaclen = 60;
  OtherChatNodes = "";
  ChatWelcomeMsg = "${CALL} Chat. Type /h for help.\$W";
  MapPosition = "${GRID}";
  MapPopup = "${CALL} DigiPi linBPQ Chat";
  PopupMode = 0;
};
EOF

chown pi:pi "${CFG}" "${LINBPQ_DIR}/chatconfig.cfg"

systemctl reset-failed linbpq 2>/dev/null || true
systemctl start linbpq
sleep 4

echo "=== apps ==="
grep -E '^APPLICATION|^LINMAIL|^LINCHAT' "${LINBPQ_DIR}/bpq32.cfg" /run/linbpq/bpq32.cfg
echo "=== chatconfig ==="
test -f /run/linbpq/chatconfig.cfg && echo "chatconfig present" || echo "chatconfig MISSING in /run"
echo "=== start lines ==="
grep -iE 'mail|chat|linmail|linchat|appl' /run/linbpq/logs/NodeDebuglog_*.log 2>/dev/null | tail -25 || true
echo "=== service ==="
systemctl is-active linbpq
