#!/bin/bash
# Integrate G8BPQ linBPQ into DigiPi as an AX.25 dashboard service.
#
# After Initialize:
#   sudo remount
#   sudo bash /boot/firmware/install-linbpq.sh
#
# Matches DigiPi node/TNC: exclusive systemd unit, own Direwolf KISS,
# home-page switch under AX.25 Node Network, Save Configuration persistence.
set -euo pipefail

LINBPQ_DIR="/home/pi/linbpq"
RUN_DIR="/run/linbpq"
WWW_INDEX="/var/www/html/index.php"
HTTP_PORT="${LINBPQ_HTTP_PORT:-8008}"
KISS_PORT="${LINBPQ_KISS_PORT:-8001}"
BETA_PI="http://www.cantab.net/users/john.wiseman/Downloads/Beta/pilinbpq"
RELEASE_PI="http://www.cantab.net/users/john.wiseman/Downloads/pilinbpq"
HTML_ZIP="http://www.cantab.net/users/john.wiseman/Downloads/Beta/HTMLPages.zip"

red() { printf '\033[1;31m%s\033[0m\n' "$*"; }
grn() { printf '\033[1;32m%s\033[0m\n' "$*"; }
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
  mount -o remount,rw / 2>/dev/null || true
  mount -o remount,rw /boot 2>/dev/null || true
  mount -o remount,rw /boot/firmware 2>/dev/null || true
}

load_station() {
  CALL="NOCALL"
  GRID="AA00aa"
  NODEPASS="abc123"
  if [[ -f /home/pi/localize.env ]]; then
    # shellcheck disable=SC1091
    source /home/pi/localize.env
  fi
  CALL="${NEWCALL:-${CALLSIGN:-${CALL}}}"
  GRID="${NEWGRID:-${GRID}}"
  CALL="$(echo "${CALL}" | tr '[:lower:]' '[:upper:]')"
  if [[ -z "${CALL}" || "${CALL}" == "NOCALL" || "${CALL}" == "KX6XXX" ]]; then
    if [[ -f /etc/ax25/axports ]]; then
      CALL="$(awk '/^radio/{print toupper($2); exit}' /etc/ax25/axports | cut -d- -f1)"
    fi
  fi
  CALL="${CALL%%-*}"
  NODEPASS="${NEWNODEPASS:-abc123}"
  if [[ -z "${NEWNODEPASS}" && -f /etc/ax25/uronode.perms ]]; then
    NODEPASS="$(awk '/^[[:alpha:]]/{print $4; exit}' /etc/ax25/uronode.perms)"
    NODEPASS="${NODEPASS:-abc123}"
  fi
  inf "Station ${CALL}  grid ${GRID}"
}

find_local_bin() {
  local p
  for p in \
    /boot/firmware/pilinbpq \
    /boot/pilinbpq \
    /home/pi/pilinbpq \
    /home/pi/install/pilinbpq \
    "${LINBPQ_DIR}/pilinbpq"
  do
    if [[ -f "${p}" && -s "${p}" ]]; then
      echo "${p}"
      return 0
    fi
  done
  return 1
}

install_binary() {
  if [[ -x "${LINBPQ_DIR}/linbpq" ]]; then
    inf "linBPQ binary already installed"
    return 0
  fi
  mkdir -p "${LINBPQ_DIR}/HTML"
  chown -R pi:pi "${LINBPQ_DIR}"

  local tmp="${LINBPQ_DIR}/.pilinbpq.download"
  local src
  if src="$(find_local_bin)"; then
    inf "Using local binary ${src}"
    cp "${src}" "${tmp}"
  else
    inf "Downloading linBPQ (official G8BPQ Raspberry Pi build)..."
    if ! wget -q -O "${tmp}" "${BETA_PI}"; then
      wget -q -O "${tmp}" "${RELEASE_PI}"
    fi
  fi
  chmod +x "${tmp}"
  mv -f "${tmp}" "${LINBPQ_DIR}/linbpq"
  chown pi:pi "${LINBPQ_DIR}/linbpq"

  local htmlzip=""
  for htmlzip in /boot/firmware/HTMLPages.zip /boot/HTMLPages.zip /tmp/HTMLPages.zip; do
    [[ -f "${htmlzip}" ]] && break
    htmlzip=""
  done
  if [[ -z "${htmlzip}" ]]; then
    if wget -q -O /tmp/HTMLPages.zip "${HTML_ZIP}"; then
      htmlzip=/tmp/HTMLPages.zip
    fi
  fi
  if [[ -n "${htmlzip}" ]] && command -v unzip >/dev/null; then
    unzip -o "${htmlzip}" -d "${LINBPQ_DIR}/HTML" >/dev/null
    chown -R pi:pi "${LINBPQ_DIR}/HTML"
  else
    inf "HTML pages not installed; linBPQ still runs. Web console may be sparse."
  fi
}

write_bpq32_cfg() {
  local cfg="${LINBPQ_DIR}/bpq32.cfg"
  GRID_UP="$(echo "${GRID}" | tr '[:lower:]' '[:upper:]')"
  if [[ "${LINBPQ_KEEP_CFG:-0}" == "1" ]] && [[ -f "${cfg}" ]] && grep -q 'DRIVER=TELNET' "${cfg}"; then
    inf "Keeping existing ${cfg}"
    return 0
  fi
  cat > "${cfg}" <<EOF
; DigiPi linBPQ - SignaLink USB + Kenwood TM-D700 DATA port
NODECALL=${CALL}-7
NODEALIAS=DIGIPI
LOCATOR=${GRID_UP}
IDINTERVAL=15
OBSINIT=6
OBSMIN=2
NODESINTERVAL=30
L3TIMETOLIVE=25
L4RETRIES=3
L4TIMEOUT=60
PACLEN=128
T3=120
IDLETIME=900
BBS=1
NODE=1
MAXLINKS=32
MAXNODES=64
MAXROUTES=32
MAXCIRCUITS=32
MINQUAL=168
HIDENODES=0
L4DELAY=10
L4WINDOW=4
BTINTERVAL=15
ENABLE_LINKED=A
FULL_CTEXT=1

IDMSG:
${CALL} linBPQ DigiPi
***

INFOMSG:
${CALL} linBPQ node on DigiPi / SignaLink / TM-D700
Packet simplex (often 145.010). Exclusive of Linux AX.25 Node Network.
***

CTEXT:
Welcome to ${CALL} linBPQ. BBS CHAT NODES PORTS BYE
***

PORT
 PORTNUM=1
 ID=Telnet/HTTP
 DRIVER=TELNET
 CONFIG
 LOGGING=1
 DisconnectOnClose=1
 TCPPORT=8010
 FBBPORT=8011
 HTTPPORT=${HTTP_PORT}
 LOGINPROMPT=user:
 PASSWORDPROMPT=password:
 MAXSESSIONS=10
 CMS=0
 USER=sysop,${NODEPASS},${CALL},,SYSOP
ENDPORT

PORT
 PORTNUM=2
 ID=Direwolf VHF 1200
 TYPE=ASYNC
 PROTOCOL=KISS
 IPADDR=127.0.0.1
 TCPPORT=${KISS_PORT}
 CHANNEL=A
 MAXFRAME=4
 FRACK=5000
 RESPTIME=1000
 RETRIES=10
 PACLEN=128
 TXDELAY=300
 SLOTTIME=100
 PERSIST=64
 FULLDUP=0
 DIGIFLAG=1
 QUALITY=192
ENDPORT

APPLICATION 1,BBS,,${CALL}-1,BBS,255
APPLICATION 2,CHAT,,${CALL}-11,CHAT,255
LINMAIL
LINCHAT
EOF
  chown pi:pi "${cfg}"
  inf "Wrote ${cfg}"
}

ensure_linmail_linchat() {
  local cfg="${LINBPQ_DIR}/bpq32.cfg"
  [[ -f "${cfg}" ]] || return 0
  if ! grep -q '^LINMAIL' "${cfg}"; then
    printf '\nLINMAIL\n' >> "${cfg}"
  fi
  if ! grep -q '^LINCHAT' "${cfg}"; then
    printf 'LINCHAT\n' >> "${cfg}"
  fi
  chown pi:pi "${cfg}"
}

write_chatconfig() {
  local cfg="${LINBPQ_DIR}/chatconfig.cfg"
  GRID_UP="$(echo "${GRID}" | tr '[:lower:]' '[:upper:]')"
  if [[ "${LINBPQ_KEEP_CFG:-0}" == "1" ]] && [[ -f "${cfg}" ]] && grep -q 'ApplNum' "${cfg}"; then
    inf "Keeping existing ${cfg}"
    return 0
  fi
  cat > "${cfg}" <<EOF
Chat :
{
  ApplNum = 2;
  MaxStreams = 10;
  chatPaclen = 60;
  OtherChatNodes = "";
  ChatWelcomeMsg = "${CALL} Chat. Type /h for help.\$W";
  MapPosition = "${GRID_UP}";
  MapPopup = "${CALL} DigiPi linBPQ Chat";
  PopupMode = 0;
};
EOF
  chown pi:pi "${cfg}"
  inf "Wrote ${cfg}"
}

write_direwolf_conf() {
  local src="/home/pi/direwolf.tnc.conf"
  local dst="/home/pi/direwolf.linbpq.conf"
  if [[ -f "${src}" ]]; then
    cp -a "${src}" "${dst}"
  else
    cat > "${dst}" <<EOF
MYCALL ${CALL}-7
DWAIT 0
TXDELAY 30
TXTAIL 10
AGWPORT 8000
KISSPORT ${KISS_PORT}
#PTT GPIOD /dev/gpiochip0 12
EOF
  fi
  # Own AX.25 node: no APRS-IS / igate beacons on the packet channel
  sed -i -E \
    -e "s/^MYCALL .*/MYCALL ${CALL}-7/" \
    -e 's/^IGSERVER/#IGSERVER/' \
    -e 's/^IGLOGIN/#IGLOGIN/' \
    -e 's/^PBEACON/#PBEACON/' \
    -e 's/^TBEACON/#TBEACON/' \
    "${dst}"
  if ! grep -q '^KISSPORT' "${dst}"; then
    printf '\nKISSPORT %s\nAGWPORT 8000\n' "${KISS_PORT}" >> "${dst}"
  fi
  chown pi:pi "${dst}"
}

write_wrapper() {
  cat > /home/pi/direwolf.linbpq.sh <<EOF
#!/bin/bash -x
# DigiPi linBPQ: Direwolf KISS + G8BPQ (no Linux ax25d).
trap ctrl_c INT
trap ctrl_c TERM
function ctrl_c() {
   sudo killall linbpq 2>/dev/null || true
   sudo killall direwolf 2>/dev/null || true
   sudo killall rfcomm 2>/dev/null || true
   sudo killall -9 direwatch.py 2>/dev/null || true
   if [[ -d ${RUN_DIR} ]] && [[ -d ${LINBPQ_DIR} ]]; then
     rsync -a ${RUN_DIR}/ ${LINBPQ_DIR}/ 2>/dev/null || true
   fi
   exit 0
}

truncate --size 0 /run/direwolf.log 2>/dev/null || true

grep -i usb /proc/asound/cards > /dev/null 2>&1
if [ \$? -eq 0 ]; then
   export ALSA_CARD=\`grep -i usb /proc/asound/cards | head -1 | cut -c 2-2\`
else
   export ALSA_CARD=0
fi

cp /home/pi/direwolf.linbpq.conf /tmp/direwolf.linbpq.conf
source <(head -n 25 /home/pi/localize.env)
USBPRESENT=\`grep "USB" /proc/asound/cards | wc -l\`
if [ "\$NEWRIGNUMBER" = DTR ]; then
  sed -i "s/\\#PTT \\/dev\\/DEVICEFILE DTR/PTT \\/dev\\/\$NEWDEVICEFILE DTR/gi" /tmp/direwolf.linbpq.conf
elif [ "\$NEWRIGNUMBER" = RTS ]; then
  sed -i "s/\\#PTT \\/dev\\/DEVICEFILE RTS/PTT \\/dev\\/\$NEWDEVICEFILE RTS/gi" /tmp/direwolf.linbpq.conf
elif [ "\$NEWRIGNUMBER" = CM108 ]; then
  sudo chown pi:audio /dev/\$NEWDEVICEFILE
  sed -i "s/\\#PTT CM108 DEVICEFILE/PTT CM108 \\/dev\\/\$NEWDEVICEFILE/" /tmp/direwolf.linbpq.conf
elif [ \$USBPRESENT -eq 0 -o "\$NEWRIGNUMBER" = GPIO ]; then
  sed -i "s/\\#PTT GPIOD/PTT GPIOD/" /tmp/direwolf.linbpq.conf
else
  sed -i "s/\\#PTT RIG RIGNUMBER DEVICEFILE/PTT RIG \$NEWRIGNUMBER \\/dev\\/\$NEWDEVICEFILE/gi" /tmp/direwolf.linbpq.conf
fi
sudo mv /tmp/direwolf.linbpq.conf /run/direwolf.linbpq.conf

sudo mkdir -p ${RUN_DIR}
sudo chown pi:pi ${RUN_DIR}
rsync -a ${LINBPQ_DIR}/ ${RUN_DIR}/
chmod +x ${RUN_DIR}/linbpq

direwolf -d t -d o -p -q d -t 0 -c /run/direwolf.linbpq.conf |& grep --line-buffered -v PTT_METHOD > /home/pi/direwolf.log &
/home/pi/direwatch.py --save "/run/direwatch.png" --log "/run/direwolf.log" --title_text "linBPQ" --display \$NEWDISPLAYTYPE >/dev/null 2>&1 &

ready=0
for _ in \$(seq 1 25); do
  if ss -ltn 2>/dev/null | grep -qE '[:.]${KISS_PORT}[[:space:]]' || netstat -ltn 2>/dev/null | grep -qE ':${KISS_PORT}[[:space:]]'; then
    ready=1
    break
  fi
  sleep 1
done
if [ "\$ready" != 1 ]; then
  echo "Direwolf KISS port ${KISS_PORT} did not open" >&2
fi

cd ${RUN_DIR} || exit 1
exec ${RUN_DIR}/linbpq
EOF
  chmod +x /home/pi/direwolf.linbpq.sh
  chown pi:pi /home/pi/direwolf.linbpq.sh

  # Compatibility name used by the dashboard docs
  cat > /home/pi/linbpq.sh <<'EOF'
#!/bin/bash
exec /home/pi/direwolf.linbpq.sh
EOF
  chmod +x /home/pi/linbpq.sh
  chown pi:pi /home/pi/linbpq.sh
}

write_unit() {
  cat > /etc/systemd/system/linbpq.service <<'EOF'
[Unit]
Description=linBPQ AX.25 node (G8BPQ)
After=network.target

[Service]
Type=simple
User=pi
WorkingDirectory=/home/pi/
ExecStartPre=+mkdir -p /run/linbpq
ExecStartPre=+chown pi:pi /run/linbpq
ExecStartPre=+systemctl stop tnc node fldigi sstv wsjtx mercury ardop tnc300b digipeater winlinkrms js8call tracker webchat
ExecStart=/home/pi/direwolf.linbpq.sh
ExecStop=/bin/bash -c 'killall linbpq 2>/dev/null; killall direwolf 2>/dev/null; killall -9 direwatch.py 2>/dev/null; rsync -a /run/linbpq/ /home/pi/linbpq/ 2>/dev/null; true'
StandardOutput=inherit
StandardError=inherit
Restart=no
TimeoutStopSec=8
KillSignal=SIGINT

[Install]
WantedBy=multi-user.target
EOF
  systemctl daemon-reload
}

patch_peer_units() {
  local f
  for f in /etc/systemd/system/*.service; do
    [[ "$(basename "${f}")" == "linbpq.service" ]] && continue
    if grep -q '^ExecStartPre=+systemctl stop ' "${f}" 2>/dev/null; then
      if grep -qE 'systemctl stop .*(tnc|node|winlinkrms)' "${f}" && ! grep -q 'linbpq' "${f}"; then
        sed -i 's/^ExecStartPre=+systemctl stop /ExecStartPre=+systemctl stop linbpq /' "${f}"
        inf "Exclusive radio: $(basename "${f}") now stops linbpq"
      fi
    fi
  done

  local boot="/etc/systemd/system/digipi-boot.service"
  if [[ -f "${boot}" ]] && ! grep -q 'start linbpq' "${boot}"; then
    sed -i '/#ExecStart=systemctl start node/a #ExecStart=systemctl start linbpq' "${boot}"
  fi
  systemctl daemon-reload
}

patch_saveconfigs() {
  local sc="/home/pi/saveconfigs.sh"
  [[ -f "${sc}" ]] || return 0
  if grep -q '/run/linbpq' "${sc}"; then
    return 0
  fi
  cp -a "${sc}" "${sc}.bak-linbpq"
  cat >> "${sc}" <<'EOF'

# linBPQ BBS/node files (runtime copy is /run/linbpq)
if [ -d /run/linbpq ]; then
  rsync -avH /run/linbpq/ /home/pi/linbpq
fi
EOF
  chown pi:pi "${sc}"
  inf "Save Configuration will persist /home/pi/linbpq"
}

allow_www_sudo() {
  local drop="/etc/sudoers.d/linbpq-www"
  cat > "${drop}" <<'EOF'
www-data ALL=(ALL) NOPASSWD: /bin/systemctl start linbpq, /bin/systemctl stop linbpq, /usr/bin/systemctl start linbpq, /usr/bin/systemctl stop linbpq, /bin/systemctl reset-failed linbpq, /usr/bin/systemctl reset-failed linbpq, /bin/systemctl is-active linbpq, /usr/bin/systemctl is-active linbpq
EOF
  chmod 440 "${drop}"
}

patch_index_php() {
  python3 - "${WWW_INDEX}" "${HTTP_PORT}" <<'PY'
import sys
from pathlib import Path

path = Path(sys.argv[1])
http_port = sys.argv[2]
text = path.read_text(encoding="utf-8", errors="surrogateescape")

backup = path.with_suffix(".php.bak-linbpq")
if not backup.exists():
    backup.write_text(text, encoding="utf-8", errors="surrogateescape")

post = '''
if (isset($_POST["linbpq"])) {
  $submit = $_POST["linbpq"];
  if ( $submit == 'on' ) {
      $output = shell_exec('sudo systemctl start linbpq');
  }
  if ( $submit == 'off' ) {
      $output = shell_exec('sudo systemctl stop linbpq');
  }
}

'''
if '$_POST["linbpq"]' not in text:
    inserted = False
    for marker in ('if (isset($_POST["wsjtx"]))', 'if (isset($_POST["fldigi"]))', 'if (isset($_POST["winlinkrms"]))'):
        if marker in text:
            text = text.replace(marker, post + marker, 1)
            inserted = True
            break
    if not inserted:
        sys.exit("Could not find a POST handler insert point in index.php")

row = r'''
#-- linBPQ AX.25 ------------------------------------

echo "<tr>";
$output = shell_exec('systemctl is-active linbpq');
$output = chop($output);
  if ($output == "active")
  {
     echo '<td bgcolor="lightgreen">';
     $checked = "checked";
  }
  elseif ($output == "failed")
  {
     echo '<td bgcolor="red">';
     $checked = "";
  }
  else
  {
     echo '<td bgcolor="lightgrey">';
     $checked = "";
  }
echo '</td>';
echo '<td>';
echo '<font size=+1>AX.25 linBPQ</font></td>';
echo '<td nowrap>';
echo '<form action="index.php" method="post">';
echo '<label class="switch switch-light">';
echo '  <input type="hidden" name="linbpq" value="off">';
echo "  <input onChange='this.form.submit()' class='switch-input' type='checkbox' name='linbpq' value='on'  $checked />";
echo '  <span class="switch-label" ></span> ';
echo '  <span class="switch-handle"></span> ';
echo '</label>';
echo '</form>';
echo '</font>';
echo '</td></tr>';

'''
if 'AX.25 linBPQ' not in text:
    placed = False
    for marker in ("#-- Winlink Server", "#-- Winlink", "echo '<font size=+1>Winlink"):
        if marker in text:
            text = text.replace(marker, row + marker, 1)
            placed = True
            break
    if not placed:
        sys.exit("Could not find Winlink section to place AX.25 linBPQ under Node")

needle = "$output = shell_exec('sudo systemctl reset-failed node 2> /dev/null');"
insert = needle + "\n$output = shell_exec('sudo systemctl reset-failed linbpq 2> /dev/null');"
if "reset-failed linbpq" not in text:
    if needle in text:
        text = text.replace(needle, insert, 1)

footer = f'''    <script language="JavaScript">
    document.write('<a href="' + window.location.protocol + '//' + window.location.hostname + ':{http_port}' + '" target="linbpq" title="linBPQ web console"><strong>linBPQ</strong></a> ' );
    </script>
'''
if 'target="linbpq"' not in text:
    for label in ("AXCall", "AX.25"):
        old = f'<a href="axcall.php" target="axcall" title="Connect to radio/BBS"><strong>{label}</strong></a>'
        if old in text:
            extra = (
                old
                + "\n  </td>\n  <td width=\"100px\">\n"
                + footer
            )
            text = text.replace(old, extra, 1)
            break

path.write_text(text, encoding="utf-8", errors="surrogateescape")
print(f"Patched {path}")
PY
}

main() {
  need_root
  remount_rw
  load_station
  command -v python3 >/dev/null || { red "python3 is required"; exit 1; }
  install_binary
  write_bpq32_cfg
  ensure_linmail_linchat
  write_chatconfig
  write_direwolf_conf
  write_wrapper
  write_unit
  patch_peer_units
  patch_saveconfigs
  allow_www_sudo
  patch_index_php
  systemctl reset-failed linbpq 2>/dev/null || true
  grn "linBPQ is integrated into DigiPi."
  inf "Refresh the home page. AX.25 linBPQ sits under AX.25 Node Network."
  inf "Web console: http://$(hostname):${HTTP_PORT}/  (user sysop)"
  inf "Do not run Linux Node and linBPQ together. Packet simplex, not 144.390."
  inf "After BBS use, click Save Configuration so /home/pi/linbpq is written to SD."
}

main "$@"
