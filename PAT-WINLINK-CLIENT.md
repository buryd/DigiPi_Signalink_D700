# DigiPi Pat Winlink Client

What the **Pat Winlink Client** switch does, which links work with it, and what those links do.

Hardware / Initialize: [PROCEDURE.md](PROCEDURE.md). Index: [DASHBOARD-SWITCHES.md](DASHBOARD-SWITCHES.md).

Hosting a gateway for others: [WINLINK-EMAIL-SERVER.md](WINLINK-EMAIL-SERVER.md) or linBPQ [AX25-LINBPQ.md](AX25-LINBPQ.md).

Dashboard: [http://digipi/](http://digipi/) or [http://10.0.0.5/](http://10.0.0.5/).

---

## 1. What it is

**Pat Winlink Client** starts **Pat** — your personal Winlink **mailbox** (compose, inbox, outbox). DigiPi exposes it over the web.

| Piece | Role |
| --- | --- |
| **Pat** | Winlink client UI and message store |
| Transport | Telnet/CMS over internet, and/or radio modems (ARDOP, packet, etc. as configured) |

This is **your** email client, not the same as **Winlink Email Server** (which listens for *other* stations).

Winlink password comes from **Initialize**. For CMS over the internet, the Pi needs **home Wi-Fi** (hotspot-only cannot reach Winlink CMS).

**This station (D700 + SignaLink):** VHF packet Pat sessions are possible in principle; **HF ARDOP / VARA-style** paths need an HF radio. Many operators use Pat over **internet/CMS** from DigiPi when online.

---

## 2. Links

| Link | When it works | What it does |
| --- | --- | --- |
| **PatEmail** | **Pat Winlink Client** green | Opens the Pat web mailbox UI |
| **SysLog** | Switch red | Pat / helper service errors |
| **Audio** | Radio transports | Levels if you are doing RF Winlink |
| **Shell** | Always | Pat config under `~/.config/pat` (after `sudo remount`) |
| **Bluetooth** | Phone apps | e.g. **Woad** as a wireless client to DigiPi TNC paths when those modems are up |

---

## 3. Link order

1. Initialize Winlink password; Pi on internet if using CMS.
2. **Pat Winlink Client** → green.
3. **PatEmail** → log in / use mailbox.
4. Choose a connection method inside Pat (telnet/CMS vs radio modem).
5. **Save Configuration** after important mailbox/config changes if advised by DigiPi practice.

If Pat needs **rigctld** for a USB/CAT radio, that may be a separate systemd unit (`/etc/systemd/system/rigctld.service`) — not used for the D700 SignaLink path.

---

## 4. Troubleshooting

| Symptom | Cause |
| --- | --- |
| PatEmail dead | Pat switch still grey |
| CMS connect fails | Hotspot-only / no internet / bad Winlink password |
| Radio connect fails | Wrong modem running, levels, or frequency |

---

DigiPi is a collective-work image from KM6LYW Radio. This document describes using it; it does not redistribute the image.
