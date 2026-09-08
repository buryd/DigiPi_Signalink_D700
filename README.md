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
sudo bash /boot/configure-signalink-d700.sh
```

## Files

| File | Purpose |
| --- | --- |
| `PROCEDURE.md` | Full install and hardware procedure |
| `install-digipi.bat` / `install-digipi.ps1` | Windows SD-card flasher |
| `install-digipi.sh` | Linux/macOS flasher |
| `scripts/configure-signalink-d700.sh` | On-Pi SignaLink ALSA / Direwolf setup |
