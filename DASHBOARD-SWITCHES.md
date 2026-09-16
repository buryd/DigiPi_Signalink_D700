# DigiPi dashboard switches (index)

Home-page **switches** start or stop services. Home-page **links** open tools in a new tab. Callsign, grid, and radio interface come from **Initialize** — switches are not a settings form.

Dashboard: [http://digipi/](http://digipi/) or [http://10.0.0.5/](http://10.0.0.5/) (hotspot).

Hardware / flash / SignaLink: [PROCEDURE.md](PROCEDURE.md).

**One radio modem at a time.** Only one of TNC/igate, Digipeater, HF TNC, Node, linBPQ, Winlink RMS, FLDigi, WSJTX, JS8Call, SSTV (etc.) should own the SignaLink.

| Switch | Document |
| --- | --- |
| **APRS TNC/igate** | [APRS-TNC-IGATE.md](APRS-TNC-IGATE.md) |
| **APRS Digipeater** | [APRS-DIGIPEATER.md](APRS-DIGIPEATER.md) |
| **APRS HF TNC/igate** | [APRS-HF-TNC-IGATE.md](APRS-HF-TNC-IGATE.md) |
| **APRS GPS Tracker** | [APRS-GPS-TRACKER.md](APRS-GPS-TRACKER.md) |
| **APRS WebChat** | [APRS-WEBCHAT.md](APRS-WEBCHAT.md) |
| **AX.25 Node Network** | [AX25-NODE.md](AX25-NODE.md) |
| **AX.25 linBPQ** | [AX25-LINBPQ.md](AX25-LINBPQ.md) (install: PROCEDURE §16) |
| **Winlink Email Server** | [WINLINK-EMAIL-SERVER.md](WINLINK-EMAIL-SERVER.md) |
| **Pat Winlink Client** | [PAT-WINLINK-CLIENT.md](PAT-WINLINK-CLIENT.md) |
| **WSJTX FT8** | [WSJTX-FT8.md](WSJTX-FT8.md) |
| **JS8Call** | [JS8CALL.md](JS8CALL.md) |
| **FLDigi** | [FLDIGI.md](FLDIGI.md) |
| **SSTV** | [SSTV.md](SSTV.md) |

Square colors: **grey** = off, **green** = running, **red** = failed → open **SysLog** / **PktLog**.

Switches do **not** survive reboot. Auto-start: edit `/etc/systemd/system/digipi-boot.service` and uncomment **one** modem `ExecStart=…` line.
