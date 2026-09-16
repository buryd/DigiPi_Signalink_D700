# DigiPi + Kenwood TM-D700 + SignaLink USB

Install helpers for running [DigiPi](https://digipi.org) on a **Raspberry Pi 3B+** with a **Tigertronics SignaLink USB** and a **Kenwood TM-D700**.

This repository does **not** include the DigiPi OS image. Download that from [digipi.org](https://digipi.org) (KM6LYW Patreon). Do not post the image online.

## Quick start

1. Read **[PROCEDURE.md](PROCEDURE.md)** (wiring, radio menus, DigiPi Initialize).
2. Place your DigiPi `.zip` or `.img` in this folder.
3. Windows: run `install-digipi.bat` as Administrator.
4. Linux/macOS: `sudo ./install-digipi.sh`
5. After DigiPi Initialize (radio interface **USB Audio, GPIO12**), on the Pi:

```bash
sudo remount
sudo bash /boot/firmware/configure-signalink-d700.sh
```

On older images the helper is `/boot/configure-signalink-d700.sh`. Do not type the filename alone; it is not on `PATH`.

6. Optional — add linBPQ (node, BBS, Chat, Winlink CMS): **[PROCEDURE.md](PROCEDURE.md) §16**.

```bash
sudo remount
sudo bash /boot/firmware/install-linbpq.sh
```

## After it boots

| Goal | What to use |
| --- | --- |
| All dashboard switches | **[DASHBOARD-SWITCHES.md](DASHBOARD-SWITCHES.md)** (index) |
| APRS igate + chat | **APRS TNC/igate**, then **APRS WebChat** — [APRS-TNC-IGATE.md](APRS-TNC-IGATE.md), [APRS-WEBCHAT.md](APRS-WEBCHAT.md) |
| APRS digipeater | **APRS Digipeater** — [APRS-DIGIPEATER.md](APRS-DIGIPEATER.md) |
| Keyboard packet (LinPac) | Node or TNC/igate on, then **AXCall** — [AX25-NODE.md](AX25-NODE.md) |
| linBPQ node / BBS / Winlink | [PROCEDURE.md](PROCEDURE.md) §16, [AX25-LINBPQ.md](AX25-LINBPQ.md) |
| Switch meanings (short) | [PROCEDURE.md](PROCEDURE.md) §12 |
| Why reboot takes ~1 minute | [PROCEDURE.md](PROCEDURE.md) §15 |

## Files

| File | Purpose |
| --- | --- |
| `PROCEDURE.md` | Hardware, flash, dashboard overview, APRS, LinPac, linBPQ (§16) |
| `DASHBOARD-SWITCHES.md` | Index of every home-page switch document |
| `APRS-TNC-IGATE.md` | **APRS TNC/igate** + links |
| `APRS-DIGIPEATER.md` | **APRS Digipeater** + links |
| `APRS-HF-TNC-IGATE.md` | **APRS HF TNC/igate** (leave off on D700) |
| `APRS-GPS-TRACKER.md` | **APRS GPS Tracker** |
| `APRS-WEBCHAT.md` | **APRS WebChat** + **Webchat** link |
| `AX25-NODE.md` | **AX.25 Node Network** |
| `AX25-LINBPQ.md` | **AX.25 linBPQ** (after install) |
| `WINLINK-EMAIL-SERVER.md` | **Winlink Email Server** |
| `PAT-WINLINK-CLIENT.md` | **Pat Winlink Client** + **PatEmail** |
| `WSJTX-FT8.md` / `JS8CALL.md` / `FLDIGI.md` / `SSTV.md` | Weak-signal / multi-mode / SSTV GUIs |
| `install-digipi.bat` / `install-digipi.ps1` | Windows SD-card flasher |
| `install-digipi.sh` | Linux/macOS flasher |
| `scripts/configure-signalink-d700.sh` | On-Pi SignaLink ALSA / Direwolf setup |
| `scripts/install-linbpq.sh` | Install linBPQ and add **AX.25 linBPQ** to the dashboard |
| `scripts/enable-linbpq-mail-chat.sh` | Existing install: start BBS (`LINMAIL`) and Chat (`LINCHAT`) |
| `scripts/enable-linbpq-winlink.sh` | Existing install: enable Winlink CMS (`RMS`) |
