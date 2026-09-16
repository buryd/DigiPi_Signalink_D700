# DigiPi Winlink Email Server

What the **Winlink Email Server** switch does, which links work with it, and what those links do.

Hardware / Initialize: [PROCEDURE.md](PROCEDURE.md). Index: [DASHBOARD-SWITCHES.md](DASHBOARD-SWITCHES.md).

For Winlink **client** mail: [PAT-WINLINK-CLIENT.md](PAT-WINLINK-CLIENT.md). For linBPQ CMS `RMS`: [AX25-LINBPQ.md](AX25-LINBPQ.md).

Dashboard: [http://digipi/](http://digipi/) or [http://10.0.0.5/](http://10.0.0.5/).

---

## 1. What it is

**Winlink Email Server** starts DigiPi’s stock **LinuxRMS**-style **gateway**: other Winlink clients can connect over RF to your station (**YOURCALL-10**) to send/receive Winlink email (when configured and online as required).

| Piece | Role |
| --- | --- |
| Direwolf / packet modem | 1200-baud path on SignaLink (VHF packet) |
| RMS server | Accepts Winlink client connects |
| Call | **YOURCALL-10** |

**Exclusive** with **AX.25 Node Network**, **linBPQ**, APRS TNC/Digipeater, and other modems.

If you use **AX.25 linBPQ** with `RMS` enabled, leave **this** DigiPi Winlink Email Server switch **off** — use linBPQ’s `RMS` instead.

Set the Winlink password in **Initialize**. The Pi usually needs **internet** for CMS-related paths depending on how you run the gateway.

---

## 2. Links

| Link | When it works | What it does |
| --- | --- | --- |
| **PktLog** | Server / modem green | See connects and packet audio (~50) |
| **Audio** | Anytime | SignaLink TX/RX levels for clean packet |
| **SysLog** | Switch red | RMS / modem start failures |
| **Shell** | Always | Service / config checks after `sudo remount` |
| **PatEmail** | Separate — **Pat** client | Your personal mailbox UI (see Pat doc), not the same as hosting RMS |

Tune to local **packet** / Winlink packet frequency used in your area (often packet simplex), not APRS 144.390 unless that is intentional.

---

## 3. Link order

1. Initialize includes Winlink password; radio TNC off; SignaLink **DLY** min.
2. All other radio modems **off**.
3. **Winlink Email Server** → green.
4. **PktLog** / **Audio** to verify the modem.
5. Remote client connects to **YOURCALL-10**.

---

## 4. Troubleshooting

| Symptom | Cause |
| --- | --- |
| Switch red | Another modem still up |
| No client connects | Frequency, levels, callsign SSID, or firewall/network |
| Conflict with linBPQ | Stop one — only one RMS-style owner of the radio |

---

DigiPi is a collective-work image from KM6LYW Radio. This document describes using it; it does not redistribute the image.
