#!/bin/bash
# One-shot: enable linBPQ Winlink CMS (RMS) using DigiPi NEWWLPASS.
# Run on the Pi: sudo bash enable-linbpq-winlink.sh
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

CALL="NOCALL"
WLPASS=""
if [[ -f /home/pi/localize.env ]]; then
  # shellcheck disable=SC1091
  source /home/pi/localize.env
  CALL="$(echo "${NEWCALL:-${CALL}}" | tr '[:lower:]' '[:upper:]')"
  WLPASS="${NEWWLPASS:-}"
fi
CALL="${CALL%%-*}"

if [[ -z "${WLPASS}" || "${CALL}" == "NOCALL" ]]; then
  echo "Need NEWCALL and NEWWLPASS in /home/pi/localize.env (DigiPi Initialize)." >&2
  exit 1
fi

[[ -f "${CFG}" ]] || { echo "Missing ${CFG}" >&2; exit 1; }

systemctl stop linbpq

export LINBPQ_CALL="${CALL}"
export LINBPQ_WLPASS="${WLPASS}"
python3 - "${CFG}" <<'PY'
import os, re, sys
from pathlib import Path

cfg = Path(sys.argv[1])
text = cfg.read_text(encoding="utf-8", errors="surrogateescape")
call = os.environ["LINBPQ_CALL"]
wpass = os.environ["LINBPQ_WLPASS"]
orig = text

text = re.sub(r"(?m)^([ \t]*)CMS=0[ \t]*$", r"\1CMS=1", text)

if not re.search(r"(?m)^[ \t]*CMSCALL=", text):
    def _cms(m):
        ind = m.group(1)
        return (
            f"{ind}CMS=1\n"
            f"{ind}CMSCALL={call}\n"
            f"{ind}CMSPASS={wpass}\n"
            f"{ind}FALLBACKTORELAY=1\n"
            f"{ind}RELAYAPPL=BBS"
        )
    text = re.sub(r"(?m)^([ \t]*)CMS=1[ \t]*$", _cms, text, count=1)
else:
    text = re.sub(r"(?m)^([ \t]*)CMSCALL=.*$", rf"\1CMSCALL={call}", text, count=1)
    if re.search(r"(?m)^[ \t]*CMSPASS=", text):
        text = re.sub(
            r"(?m)^([ \t]*)CMSPASS=.*$",
            lambda m: f"{m.group(1)}CMSPASS={wpass}",
            text,
            count=1,
        )
    else:
        text = re.sub(
            r"(?m)^([ \t]*)CMSCALL=.*$",
            lambda m: f"{m.group(1)}CMSCALL={call}\n{m.group(1)}CMSPASS={wpass}",
            text,
            count=1,
        )
    if not re.search(r"(?m)^[ \t]*FALLBACKTORELAY=", text):
        text = re.sub(
            r"(?m)^([ \t]*)CMSPASS=.*$",
            lambda m: (
                f"{m.group(1)}CMSPASS={wpass}\n"
                f"{m.group(1)}FALLBACKTORELAY=1\n"
                f"{m.group(1)}RELAYAPPL=BBS"
            ),
            text,
            count=1,
        )

app = f"APPLICATION 3,RMS,C 1 CMS,{call}-10,RMS,255"
if not re.search(r"(?m)^APPLICATION [0-9]+,RMS,", text):
    text = text.rstrip() + "\n" + app + "\n"

text = re.sub(
    r"(Welcome to [^\n]* linBPQ\. )BBS CHAT(?! RMS)",
    r"\1BBS CHAT RMS",
    text,
    count=1,
)

cfg.write_text(text, encoding="utf-8", errors="surrogateescape")
print("patched" if text != orig else "already_set")
PY
unset LINBPQ_WLPASS LINBPQ_CALL
chown pi:pi "${CFG}"

systemctl reset-failed linbpq 2>/dev/null || true
systemctl start linbpq
sleep 4

echo "=== cms/rms (password omitted) ==="
grep -E '^[[:space:]]*CMS=|^[[:space:]]*CMSCALL=|^[[:space:]]*FALLBACK|^[[:space:]]*RELAYAPPL=|^APPLICATION .*,RMS,' \
  "${CFG}" /run/linbpq/bpq32.cfg
echo "=== service ==="
systemctl is-active linbpq
echo "Test: linBPQ Terminal, type RMS. Needs internet (home Wi-Fi, not hotspot-only)."
