# DigiPi JS8Call

What the **JS8Call** switch does, which links work with it, and what those links do.

Hardware / Initialize: [PROCEDURE.md](PROCEDURE.md). Index: [DASHBOARD-SWITCHES.md](DASHBOARD-SWITCHES.md).

Dashboard: [http://digipi/](http://digipi/) or [http://10.0.0.5/](http://10.0.0.5/).

---

## 1. What it is

Starts **JS8Call** — weak-signal keyboard-to-keyboard messaging (JS8). DigiPi serves the GUI via web/VNC like WSJT-X.

**Exclusive** with other radio modems/apps on the SignaLink / primary audio device.

**This station (TM-D700 + SignaLink):** poor fit (same reasons as FT8 — wants SSB/data radio with proper audio/CAT). Leave **off** for normal D700 packet/APRS use.

---

## 2. Links

| Link | When it works | What it does |
| --- | --- | --- |
| **JS8Call** (home page) | Switch green | Open the JS8Call UI (web or via VNC) |
| **Audio** | Anytime | Correct capture/playback device and levels |
| **SysLog** | Switch red | Start failures (device busy, display) |
| **Shell** | Always | Config / process checks |
| VNC | Optional | `digipi:5901` — easier on a phone |

---

## 3. Link order

1. Stop APRS / Node / Winlink / FLDigi / WSJT-X.
2. **JS8Call** → green.
3. Open **JS8Call** link or VNC; set band/mode on the radio.
4. **Audio** → verify levels; **Save Configuration** if you changed mixer settings.

---

## 4. Troubleshooting

| Symptom | Cause |
| --- | --- |
| Switch red | Sound card held by another DigiPi mode |
| No activity | Wrong radio mode, frequency, or audio device |

---

DigiPi is a collective-work image from KM6LYW Radio. This document describes using it; it does not redistribute the image.
