# DigiPi APRS GPS Tracker

What the **APRS GPS Tracker** switch does, which links work with it, and what those links do.

Hardware / Initialize: [PROCEDURE.md](PROCEDURE.md). Index: [DASHBOARD-SWITCHES.md](DASHBOARD-SWITCHES.md).

Dashboard: [http://digipi/](http://digipi/) or [http://10.0.0.5/](http://10.0.0.5/).

---

## 1. What it is

**APRS GPS Tracker** starts DigiPi’s mobile **GPS beacon** path: read position from a GPS receiver and send APRS position beacons (via Direwolf / tracker config).

| Needs | Notes |
| --- | --- |
| **GPS hardware** | USB GPS, HAT GPS, or other device DigiPi Initialize can see |
| **Radio modem** | Usually used with APRS TNC or Digipeater audio path configured |

Without a GPS, the switch is not useful — leave **OFF** on a fixed home igate that has no GPS plugged in.

Fixed home stations that only need a map presence usually use **APRS TNC/igate** with `PBEACON sendto=IG` (internet-only beacon) instead of the GPS Tracker switch. See [APRS-TNC-IGATE.md](APRS-TNC-IGATE.md).

---

## 2. Related switches

| Switch | Role |
| --- | --- |
| **APRS GPS Tracker** | ON when you want live GPS beacons |
| **APRS TNC/igate** or **Digipeater** | Modem that actually keys the radio (one at a time) |
| **APRS WebChat** | Optional messaging while the modem is up |

---

## 3. Links

| Link | What it does |
| --- | --- |
| **PacketLog** | Confirm beacons and audio when a modem is also running |
| **SysLog** | Tracker / GPS service errors |
| **Shell** | Check GPS devices (`/dev/tty*`, `gps*` tools) |
| **SystemInfo** / GPS viewer (if present on your image) | Grid / fix status on newer DigiPi builds |
| [aprs.fi](https://aprs.fi) | Confirm your moving call appears on the map |

---

## 4. Quick check

1. GPS plugged in and visible after Initialize / reboot.
2. Start the APRS modem you intend (**TNC/igate** or **Digipeater**).
3. Start **APRS GPS Tracker**.
4. **PacketLog** / aprs.fi — position updates.

---

DigiPi is a collective-work image from KM6LYW Radio. This document describes using it; it does not redistribute the image.
