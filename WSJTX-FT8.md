# DigiPi WSJTX FT8

What the **WSJTX** / **FT8** switch does, which links work with it, and what those links do.

Hardware / Initialize: [PROCEDURE.md](PROCEDURE.md). Index: [DASHBOARD-SWITCHES.md](DASHBOARD-SWITCHES.md).

Dashboard: [http://digipi/](http://digipi/) or [http://10.0.0.5/](http://10.0.0.5/).

---

## 1. What it is

Starts **WSJT-X** for **FT8** (and related weak-signal modes in that app). DigiPi runs the GUI on a virtual display and lets you use it from a phone/PC browser or **VNC**.

| Piece | Role |
| --- | --- |
| WSJT-X | Encode/decode FT8 |
| Audio / CAT | Radio interface from Initialize (USB audio radios work best) |

**Exclusive** with APRS TNC, Digipeater, Node, linBPQ, Winlink RMS, FLDigi, JS8Call, SSTV, etc.

**This station (TM-D700 + SignaLink):** a **poor fit**. FT8 expects stable SSB/USB (or a radio DigiPi can CAT-control). The D700 DATA jack path is for FM packet, not typical HF/VHF FT8 ops. Prefer a USB-connected SSB/data radio for this switch.

---

## 2. Links

| Link | When it works | What it does |
| --- | --- | --- |
| **WSJTX** / FT8 app link (home page) | Switch green | Open the web/VNC view of WSJT-X |
| **Audio** | Anytime | Set playback/capture so WSJT-X sees the right card and levels |
| **SysLog** | Switch red | Why WSJT-X failed to start (often sound device busy) |
| **Shell** | Always | Advanced checks |
| VNC | Optional | Host `digipi:5901`, password often `test11` on stock DigiPi — easier typing than tiny web UI |

---

## 3. Link order

1. All other radio apps **off**.
2. Radio interface matches Initialize (USB/CAT radio recommended).
3. **WSJTX** → green.
4. Open the WSJT-X link or VNC; set frequency/mode in the radio and in WSJT-X.
5. **Audio** if the waterfall is dead or overdriven.
6. **Save Configuration** after audio/app tweaks.

---

## 4. Troubleshooting

| Symptom | Cause |
| --- | --- |
| Switch red | Another modem still holding the sound card |
| No decode | Wrong sound device, level, or radio mode/band |
| D700 path | Use a different radio for FT8 |

---

DigiPi is a collective-work image from KM6LYW Radio. This document describes using it; it does not redistribute the image.
