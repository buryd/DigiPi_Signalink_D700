# DigiPi AX.25 linBPQ

What the **AX.25 linBPQ** switch does, which links work with it, and what those links do.

**Install and full ops:** [PROCEDURE.md](PROCEDURE.md) §16. Index: [DASHBOARD-SWITCHES.md](DASHBOARD-SWITCHES.md).

Stock DigiPi does **not** include this switch until you run `scripts/install-linbpq.sh`.

Dashboard: [http://digipi/](http://digipi/) or [http://10.0.0.5/](http://10.0.0.5/).

---

## 1. What it is

**AX.25 linBPQ** starts **G8BPQ linBPQ** plus its **own** Direwolf (KISS on port **8001**) on the SignaLink.

| Piece | Role |
| --- | --- |
| Direwolf (linBPQ) | 1200-baud modem → D700 |
| linBPQ | Node, BBS, Chat, optional Winlink CMS |
| Node call | **YOURCALL-7** |

**Not** the APRS igate and **not** Linux **AX.25 Node Network**. Leave those **off**. Also leave DigiPi **Winlink Email Server** off when using linBPQ `RMS`.

Tune to **packet simplex** (often 145.010 / 145.030), not 144.390.

---

## 2. Links

| Link | When it works | What it does |
| --- | --- | --- |
| **linBPQ** | Switch green | Web UI — [http://digipi:8008/](http://digipi:8008/). Login **`sysop`** / DigiPi **node password** (Initialize; default `abc123`), not the Linux `pi` password |
| **PacketLog** | Switch green | Direwolf traffic for the linBPQ modem |
| **Audio** | Anytime | SignaLink levels |
| **SysLog** | Switch red | Why linBPQ / Direwolf failed |
| **Shell** | Always | Edit `/home/pi/linbpq/` after stop + `sudo remount` (see PROCEDURE §16) |
| **AX.25** | Not the primary linBPQ UI | Prefer the **linBPQ** web terminal for BPQ commands |

---

## 3. Link order

1. Install linBPQ (PROCEDURE §16) if the switch is missing.
2. Pi on **home Wi-Fi** if you need Winlink CMS.
3. Packet simplex on the D700; other modems **off**.
4. **AX.25 linBPQ** → green.
5. **linBPQ** link → `sysop` login.
6. In terminal: `BBS`, `CHAT`, or `RMS` as enabled.
7. **Save Configuration** after use so `/run/linbpq` is written back to the SD card.

---

## 4. Applications / SSIDs

| Command | Application | Call |
| --- | --- | --- |
| (node) | Switch | **YOURCALL-7** |
| `BBS` | Mail | **YOURCALL-1** |
| `CHAT` | Chat | **YOURCALL-11** |
| `RMS` | Winlink CMS | **YOURCALL-10** |

Ports: **1** = telnet/HTTP/CMS (internet); **2** = radio. Do not `c 1` for an RF station.

---

## 5. Troubleshooting

| Symptom | Cause |
| --- | --- |
| No switch on home page | Run `install-linbpq.sh`, hard-refresh |
| Switch red | Another modem up; `sudo systemctl reset-failed linbpq` |
| `sysop` rejected | Wrong password — use Initialize node password |
| `RMS` fails | No internet (hotspot-only) or no Winlink password — `enable-linbpq-winlink.sh` |

---

DigiPi is a collective-work image from KM6LYW Radio. This document describes using it; it does not redistribute the image.
