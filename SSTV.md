# DigiPi SSTV

What the **SSTV** switch does, which links work with it, and what those links do.

Hardware / Initialize: [PROCEDURE.md](PROCEDURE.md). Index: [DASHBOARD-SWITCHES.md](DASHBOARD-SWITCHES.md).

Dashboard: [http://digipi/](http://digipi/) or [http://10.0.0.5/](http://10.0.0.5/).

---

## 1. What it is

Starts DigiPi’s **Slow-Scan TV** app (typically **qSSTV**) so you can send/receive SSTV images from a browser or VNC.

**Exclusive** with other radio modems/apps that own the sound card.

**This station (TM-D700 + SignaLink):** possible on **FM** SSTV if you choose an appropriate frequency and levels, but it is a specialized mode — leave **off** unless you are intentionally doing SSTV. Do not run it while APRS Digipeater/TNC is on.

---

## 2. Links

| Link | When it works | What it does |
| --- | --- | --- |
| **SSTV** (home page) | Switch green | Open the SSTV application UI |
| **Audio** | Anytime | TX/RX levels so images are not washed out or thin |
| **SysLog** | Switch red | App / display / audio start errors |
| **Shell** | Always | Advanced recovery |
| VNC | Optional | Comfortable image viewing/sending on a phone or PC |

---

## 3. Link order

1. Stop APRS / Node / Winlink / FLDigi / WSJT-X / JS8Call.
2. Tune the radio to the SSTV frequency you intend.
3. **SSTV** → green.
4. Open **SSTV** link or VNC.
5. **Audio** → trim; **Save Configuration** if levels change.

---

## 4. Troubleshooting

| Symptom | Cause |
| --- | --- |
| Switch red | Sound device busy |
| Bad pictures | Levels, deviation, or wrong mode/frequency |

---

DigiPi is a collective-work image from KM6LYW Radio. This document describes using it; it does not redistribute the image.
