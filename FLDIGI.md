# DigiPi FLDigi

What the **FLDigi** switch does, which links work with it, and what those links do.

Hardware / Initialize: [PROCEDURE.md](PROCEDURE.md). Index: [DASHBOARD-SWITCHES.md](DASHBOARD-SWITCHES.md).

Dashboard: [http://digipi/](http://digipi/) or [http://10.0.0.5/](http://10.0.0.5/).

---

## 1. What it is

Starts **fldigi** — multi-mode digital (PSK31, RTTY, Olivia, CW helpers, WeatherFax, and many others). DigiPi runs it on a virtual display for browser/VNC use.

**Exclusive** with APRS Direwolf stacks, Node, linBPQ, Winlink RMS, WSJT-X, JS8Call, SSTV, etc.

**This station (TM-D700 + SignaLink):** limited. Some FM digital experiments are possible, but fldigi is aimed at **SSB/HF** (or radios DigiPi CAT-controls). Prefer leaving **off** for day-to-day D700 APRS/packet; use **APRS TNC/igate** or **Node** instead.

---

## 2. Links

| Link | When it works | What it does |
| --- | --- | --- |
| **FLDigi** (home page) | Switch green | Open the fldigi UI |
| **Audio** | Anytime | Point fldigi at SignaLink capture/playback; set levels |
| **SysLog** | Switch red | Why fldigi did not start |
| **Shell** | Always | Config under fldigi trees (often mirrored under `/run`) |
| VNC | Optional | Easier UI than the compressed web view |

---

## 3. Link order

1. All other radio services **off**.
2. **FLDigi** → green.
3. Open **FLDigi** link or VNC; pick mode/freq on radio + in fldigi.
4. **Audio** → adjust; **Save Configuration** after good levels.

---

## 4. Troubleshooting

| Symptom | Cause |
| --- | --- |
| Switch red | Direwolf/another app still using USB audio |
| Silence / overload | Capture device or level — use **Audio** + waterfall |

---

DigiPi is a collective-work image from KM6LYW Radio. This document describes using it; it does not redistribute the image.
