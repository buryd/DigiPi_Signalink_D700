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

## After it boots

| Goal | What to use |
| --- | --- |
| APRS igate + chat | Dashboard **APRS TNC/igate**, then **APRS WebChat** |
| Keyboard packet (LinPac) | TNC/igate or Node on, then **AXCall** → LinPac |
| Switch meanings | [PROCEDURE.md](PROCEDURE.md) §12 |
| Why reboot takes ~1 minute | [PROCEDURE.md](PROCEDURE.md) §15 |

## Files

| File | Purpose |
| --- | --- |
| `PROCEDURE.md` | Hardware, flash, dashboard, APRS, LinPac |
| `install-digipi.bat` / `install-digipi.ps1` | Windows SD-card flasher |
| `install-digipi.sh` | Linux/macOS flasher |
| `scripts/configure-signalink-d700.sh` | On-Pi SignaLink ALSA / Direwolf setup |
