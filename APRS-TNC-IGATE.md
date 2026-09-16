# DigiPi APRS TNC / IGate

What the **APRS TNC/igate** switch does, which home-page **links** work with it, and what those links do. All switches: [DASHBOARD-SWITCHES.md](DASHBOARD-SWITCHES.md).

Hardware wiring, radio menus, and Initialize: [PROCEDURE.md](PROCEDURE.md) §1–§8. This document assumes those are done (Kenwood **TM-D700** + **SignaLink USB** station).

Dashboard: [http://digipi/](http://digipi/) or [http://10.0.0.5/](http://10.0.0.5/) (hotspot).

---

## 1. Two jobs, one switch

The **APRS TNC/igate** square starts one Direwolf process that does two different jobs. Blame the right half when something fails.

| Half | What it is | Depends on |
| --- | --- | --- |
| **TNC** | Direwolf as a **1200-baud** AFSK software modem on SignaLink USB audio | Radio, audio levels, jumpers |
| **IGate** | Decoded RF packets forwarded to the **APRS-IS** internet network | Wi-Fi, callsign, APRS passcode |

The D700 stays an **analog FM** radio. Its built-in TNC must be **off** — DigiPi is the TNC.

Igate callsign: **YOURCALL-2**.

**Not a digipeater.** TNC/igate does not repeat `WIDE1-1` on RF — that is the separate **APRS Digipeater** switch. Do not run both.

**One radio modem at a time.** Starting TNC/igate stops digipeater, node, linBPQ, Winlink RMS, FLDigi, and the rest.

---

## 2. Signal path

```
                 144.390 FM (US APRS)
                     |
              D700 DATA jack (6-pin mini-DIN)
                     |
            SignaLink USB (USB audio + VOX PTT)
                     |
                  Direwolf
                     |
        +------------+-------------+
        |                          |
   RF decode                 WebChat / KISS / LinPac
        |                          |
   APRS-IS upload            SignaLink VOX
   (YOURCALL-2)                    |
        |                     D700 keys TX
     aprs.fi
```

---

## 3. Links that work with APRS TNC/igate

Home page **switches** start services. Home page **links** (bottom row and related) open tools in a new tab. Most APRS links only make sense when **APRS TNC/igate** is **green**.

### Related switches (turn these on first)

| Switch | Role with TNC/igate |
| --- | --- |
| **APRS TNC/igate** | Must be **ON** — modem + internet gateway |
| **APRS WebChat** | Turn **ON after** TNC/igate — needed before the **Webchat** link works |
| **APRS Digipeater** | Leave **OFF** while using TNC/igate |
| **APRS HF TNC/igate** | Leave **OFF** (D700 is VHF FM) |
| **APRS GPS Tracker** | Optional; needs a GPS receiver — not required for basic igate |

### Links that use the TNC / igate

| Link | When it works | What it does |
| --- | --- | --- |
| **Webchat** | **APRS TNC/igate** green **and** **APRS WebChat** green | Browser APRS messaging (APRSd). Send/receive APRS messages and beacons over RF (via Direwolf KISS). Default path stays RF-centric so messaging still works if the internet drops. |
| **PacketLog** | **APRS TNC/igate** green | Live Direwolf packet log. Shows decoded stations and **audio average** (aim near **50**, usable ~10–90). Best tool to prove the radio path is working. |
| **Audio** | Always available; use with TNC up | Opens the mixer (**alsamixer**) for SignaLink **playback (TX)** and **capture (RX)**. Adjust here, then confirm levels in **PacketLog**. Press **Save Configuration** after good levels. |
| **SysLog** | Always; use when a switch goes **red** | System / service log. Shows why Direwolf or WebChat failed to start (sound card busy, another modem still running, config error). |
| **AX.25** | **APRS TNC/igate** (or Node) green | Browser terminal into **LinPac** (`axcall.php`) — keyboard packet over the same 1200-baud modem. Tune the radio to **packet simplex** (often 145.010 / 145.050) unless you intend to chat on APRS 144.390. |
| **Shell** | Always | Browser command shell on the Pi (`sudo remount`, edits, `systemctl`, etc.). |
| **Bluetooth** | Pairing for phone apps | Pair a phone so apps like **APRSDroid** can use DigiPi as a wireless KISS TNC (same Direwolf stack when TNC/igate is on). |

### Useful external link (not on the DigiPi page)

| Link | What it does |
| --- | --- |
| [aprs.fi](https://aprs.fi) | Public APRS map. Search **YOURCALL-2** to confirm the **IGate** half reached APRS-IS. |

### Link order for a normal APRS session

1. **APRS TNC/igate** → ON (green).
2. **PacketLog** → confirm other stations decode; audio ~50.
3. **APRS WebChat** → ON (green).
4. **Webchat** → send a message or beacon.
5. [aprs.fi](https://aprs.fi) → confirm **YOURCALL-2**.
6. Optional: **Audio** to trim levels; **AX.25** for LinPac on packet simplex; **SysLog** if anything turns red.

If **Webchat** does nothing: WebChat switch is still off, or TNC/igate was never started.

---

## 4. Bring it up (radio checklist)

1. **Radio** — D700 on **144.390 FM** (US), internal TNC **off**, APRS **off**, radio VOX **off**, menu **1-9-6 = 1200**, squelch just closed, low power.
2. **SignaLink** — **DLY** fully counterclockwise. **TX** ~9–10 o’clock. **RX** ~12 o’clock.
3. Dashboard — **APRS TNC/igate** ON, then use the links in §3.

### SSIDs

| Service | Call |
| --- | --- |
| **APRS TNC/igate** | **YOURCALL-2** |
| AX.25 Node Network | YOURCALL-4 |
| linBPQ node | YOURCALL-7 |
| Winlink RMS | YOURCALL-10 |
| LinPac | YOURCALL (no SSID) |

---

## 5. Which half is broken

| PacketLog decodes? | On aprs.fi? | Conclusion |
| --- | --- | --- |
| Yes | Yes | Both halves working. |
| **Yes** | **No** | Radio OK. **IGate** problem: internet, callsign, or APRS passcode. |
| **No** | No | **TNC** problem: audio, jumpers, frequency, or radio TNC still on. |
| No | Yes (position only) | Internet beacon works; deaf on RF — still a TNC problem. |

A decode in **PacketLog** proves antenna → radio → DATA jack → SignaLink → USB → modem. Stop chasing audio once that works.

---

## 6. Beacons: RF versus internet

| Config line | Where it goes |
| --- | --- |
| `PBEACON sendto=IG …` | APRS-IS only (shows on aprs.fi, no RF) |
| `PBEACON …` (no `sendto`) | Transmitted on RF |
| `TBEACON …` | Tracker beacon on RF |

Fixed igates normally use `sendto=IG`.

---

## 7. Under the hood

| Item | Path |
| --- | --- |
| Direwolf config | `/home/pi/direwolf.tnc.conf` |
| Runtime copy | under `/run` (rebuilt every start) |
| Station identity | `/home/pi/localize.env` |
| systemd unit | `tnc.service` |
| Log for PacketLog | Direwolf log |
| Front display | `direwatch.py` |

```bash
sudo remount
sudo nano /home/pi/direwolf.tnc.conf
```

Restart the switch (off, then on). Do not edit only the copy under `/run`.

After `sudo sed`, restore ownership:

```bash
sudo chown pi:pi /home/pi/direwolf.tnc.conf
```

---

## 8. Auto-start at boot

Switch positions do **not** survive reboot. To auto-start IGate:

```bash
sudo remount
sudo nano /etc/systemd/system/digipi-boot.service
```

Uncomment **one** `ExecStart=systemctl start tnc` line. Leave other modem lines commented.

**Save Configuration** does not store switches; it saves the RAM overlay (audio, app files, logs). Use it after **Audio** changes.

---

## 9. Troubleshooting

| Symptom | Cause |
| --- | --- |
| No USB sound card | SignaLink unplugged, cheap hub, weak PSU |
| PacketLog idle, no decodes | Wrong jumpers/band/volume; radio TNC still on |
| Garbled decodes | RX level wrong — aim PacketLog ~50 |
| TX audio, radio never keys | SignaLink **TX** / Pi playback too low; Speaker muted in **Audio**; PTT jumper missing |
| Radio stays keyed | SignaLink **DLY** not at minimum |
| Decodes OK, nothing on aprs.fi | IGate: internet / `MYCALL` / passcode |
| Switch red | **SysLog** — another modem still up, or sound card busy |
| Webchat link dead | Start **APRS TNC/igate**, then **APRS WebChat**, then **Webchat** |

---

## 10. Quick reference

| Item | Value |
| --- | --- |
| Frequency (US) | 144.390 MHz FM simplex |
| Baud | 1200 AFSK |
| Igate call | YOURCALL-2 |
| Radio internal TNC | Off |
| SignaLink DLY | Fully CCW |
| PacketLog audio target | ~50 |
| Dashboard | http://digipi/ or http://10.0.0.5/ |
| Writable filesystem | `sudo remount` |

---

DigiPi is a collective-work image from KM6LYW Radio. This document describes using it; it does not redistribute the image.
