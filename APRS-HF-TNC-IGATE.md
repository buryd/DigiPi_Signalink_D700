# DigiPi APRS HF TNC / IGate

What the **APRS HF TNC/igate** switch does, which links work with it, and what those links do.

Hardware / Initialize: [PROCEDURE.md](PROCEDURE.md). Index of all switches: [DASHBOARD-SWITCHES.md](DASHBOARD-SWITCHES.md).

Dashboard: [http://digipi/](http://digipi/) or [http://10.0.0.5/](http://10.0.0.5/).

---

## 1. What it is

**APRS HF TNC/igate** starts Direwolf as a **300-baud** HF packet modem (and internet gateway), for HF APRS (for example around **10.1476 MHz** USB, depending on band plan).

| Half | Role |
| --- | --- |
| **TNC** | 300-baud AFSK modem on the selected audio interface |
| **IGate** | Decoded HF packets can be forwarded to APRS-IS |

**This station (TM-D700 + SignaLink):** leave **OFF**. The D700 is a VHF/UHF FM radio. Use **[APRS TNC/igate](APRS-TNC-IGATE.md)** (1200 baud) on **144.390** instead.

Exclusive with other radio modems (VHF TNC, Digipeater, Node, Winlink RMS, FLDigi, …).

---

## 2. Links (when HF TNC is green)

| Link | What it does |
| --- | --- |
| **PktLog** | Direwolf log and audio levels for the HF modem |
| **Webchat** | After **APRS WebChat** is also on — messaging over the HF KISS path |
| **Audio** | Mixer for TX/RX levels |
| **SysLog** | Why the switch went red |
| **Shell** | Pi command shell |

---

## 3. When you would use it

Only with an **HF** radio (USB audio / CAT as configured in Initialize), not the D700 DATA jack path used for VHF APRS.

---

DigiPi is a collective-work image from KM6LYW Radio. This document describes using it; it does not redistribute the image.
