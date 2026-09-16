# DigiPi AX.25 Node Network

What the **AX.25 Node Network** switch does, which links work with it, and what those links do.

Hardware / Initialize: [PROCEDURE.md](PROCEDURE.md) (§14 LinPac). Index: [DASHBOARD-SWITCHES.md](DASHBOARD-SWITCHES.md).

For G8BPQ linBPQ (separate switch): [AX25-LINBPQ.md](AX25-LINBPQ.md).

Dashboard: [http://digipi/](http://digipi/) or [http://10.0.0.5/](http://10.0.0.5/).

---

## 1. What it is

**AX.25 Node Network** starts DigiPi’s stock Linux **AX.25** stack and **node** (uronode-style): a radio-connected **node / BBS-style** service on callsign **YOURCALL-4**.

| Piece | Role |
| --- | --- |
| Direwolf (or AX.25 attach) | 1200-baud modem on SignaLink |
| Node | Listen / connect for keyboard packet users |
| Call | **YOURCALL-4** |

**Exclusive** with **APRS TNC/igate**, Digipeater, **linBPQ**, DigiPi **Winlink Email Server**, and the GUI digi modes — one modem owns the SignaLink.

Tune the D700 to local **packet simplex** (often **145.010 / 145.050**), not APRS **144.390**, unless you intentionally want node traffic on the APRS channel.

---

## 2. Links

| Link | When it works | What it does |
| --- | --- | --- |
| **AXCall** | Node (or TNC) green | Browser terminal into **LinPac** / `axcall` for keyboard packet |
| **PktLog** | Modem green | Packet decode / TX log and audio average (~50) |
| **Audio** | Anytime | SignaLink TX/RX mixer |
| **SysLog** | Switch red | Node / modem failures |
| **Shell** | Always | `axcall radio OTHERCALL`, config edits after `sudo remount` |
| **Bluetooth** | Paired phone | Phone apps as wireless KISS clients when the modem is up |

**LinPac is not a switch.** Start **AX.25 Node Network** (or **APRS TNC/igate**), then open **AXCall**.

---

## 3. Link order

1. D700 on packet simplex, internal TNC off, SignaLink **DLY** min.
2. Leave linBPQ / APRS TNC / Winlink RMS **off**.
3. **AX.25 Node Network** → green.
4. **AXCall** → LinPac; `mycall` = **YOURCALL** (no SSID).
5. Optional: **PktLog** / **Audio** to verify levels.

---

## 4. SSIDs (stock DigiPi)

| Service | Call |
| --- | --- |
| AX.25 Node Network | **YOURCALL-4** |
| LinPac | YOURCALL (no SSID) |
| APRS TNC/igate | YOURCALL-2 |
| linBPQ node | YOURCALL-7 |

---

## 5. Troubleshooting

| Symptom | Cause |
| --- | --- |
| Switch red | Another modem still up — **SysLog** |
| Truncated callsign in LinPac | Initialize drop — PROCEDURE §14 |
| No connects | Wrong frequency; levels; radio TNC still on |

---

DigiPi is a collective-work image from KM6LYW Radio. This document describes using it; it does not redistribute the image.
