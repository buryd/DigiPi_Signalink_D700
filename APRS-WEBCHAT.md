# DigiPi APRS WebChat

What the **APRS WebChat** switch does, which links work with it, and what those links do.

Hardware / Initialize: [PROCEDURE.md](PROCEDURE.md). Index: [DASHBOARD-SWITCHES.md](DASHBOARD-SWITCHES.md).

Modem docs: [APRS-TNC-IGATE.md](APRS-TNC-IGATE.md), [APRS-DIGIPEATER.md](APRS-DIGIPEATER.md).

Dashboard: [http://digipi/](http://digipi/) or [http://10.0.0.5/](http://10.0.0.5/).

---

## 1. What it is

**APRS WebChat** starts the **APRSd WebChat** service — a browser UI for APRS **messages** and beacons. It is **not** a radio modem by itself.

It talks to Direwolf over **KISS** (typically `localhost:8001`). Something else must already be providing that TNC:

| First turn ON | Then |
| --- | --- |
| **APRS TNC/igate** (preferred for messaging + map upload) | **APRS WebChat** → **Webchat** link |
| **APRS Digipeater** | **APRS WebChat** → **Webchat** link |

If you open **Webchat** with only WebChat green and no modem, it fails (connection refused to KISS).

Default DigiPi WebChat is **RF-centric** (via KISS). It can be pointed at APRS-IS only by editing `~/.config/aprsd/aprsd.conf` (`aprs_network` / `aprs_kiss`) — advanced; stock stays RF so messaging still works if the internet drops.

---

## 2. Links

| Link | When it works | What it does |
| --- | --- | --- |
| **Webchat** | Modem green **and** **APRS WebChat** green | Open the messaging UI (send/receive APRS text, beacon) |
| **PacketLog** | Modem green | See your TX/RX packets and audio level |
| **Audio** | Anytime | Trim SignaLink levels so WebChat TX keys cleanly |
| **SysLog** | Switch red | WebChat or modem start errors |
| [aprs.fi](https://aprs.fi) | After igate path works | Confirm YOURCALL-2 / messages that reached the internet |

---

## 3. Link order

1. Radio on **144.390** (US), SignaLink **DLY** min, internal TNC off.
2. **APRS TNC/igate** (or Digipeater) → green.
3. **PacketLog** → audio ~50, other stations decode.
4. **APRS WebChat** → green.
5. **Webchat** → send a test message or beacon.

---

## 4. Troubleshooting

| Symptom | Cause |
| --- | --- |
| Webchat blank / error | Modem not started first |
| No RF key-up | SignaLink TX/playback too low; **Audio**; DLY |
| Message sent, no map | IGate half — see [APRS-TNC-IGATE.md](APRS-TNC-IGATE.md) §5 |

---

DigiPi is a collective-work image from KM6LYW Radio. This document describes using it; it does not redistribute the image.
