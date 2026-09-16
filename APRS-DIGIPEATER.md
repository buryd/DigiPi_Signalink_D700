# DigiPi APRS Digipeater

What the **APRS Digipeater** switch does, which home-page **links** work with it, and what those links do.

Hardware wiring, radio menus, and Initialize: [PROCEDURE.md](PROCEDURE.md) §1–§8. This document assumes those are done (Kenwood **TM-D700** + **SignaLink USB** station).

For the other APRS modem switch (internet gateway, no RF digipeat): **[APRS-TNC-IGATE.md](APRS-TNC-IGATE.md)**. All switches: [DASHBOARD-SWITCHES.md](DASHBOARD-SWITCHES.md).

Dashboard: [http://digipi/](http://digipi/) or [http://10.0.0.5/](http://10.0.0.5/) (hotspot).

---

## 1. What APRS Digipeater is

The **APRS Digipeater** square starts a **1200-baud Direwolf** process that is a software **TNC** on the SignaLink **and** a store-and-forward **digipeater** on RF.

| Job | What it does |
| --- | --- |
| **TNC** | Decodes and encodes 1200-baud AFSK on SignaLink USB audio (same radio path as TNC/igate) |
| **Digipeat** | Re-transmits packets that request a hop (typically **`WIDE1-1`**) so stations farther out can be heard |
| **Limited IG → RF** | Relays **message-type** packets from APRS-IS to RF for stations roughly within **~160 km** of you (not the whole APRS-IS feed) |

The D700 stays an **analog FM** radio. Its built-in TNC must be **off** — DigiPi/Direwolf is the TNC.

**Not the same as TNC/igate.**

| Switch | RF digipeat (`WIDE1-1`) | Main internet role |
| --- | --- | --- |
| **APRS Digipeater** | Yes | Digi + nearby message relay; config in `direwolf.digipeater.conf` |
| **APRS TNC/igate** | No | Full RF → APRS-IS upload as **YOURCALL-2** |

**Do not run both.** One radio modem at a time — Direwolf cannot share the SignaLink with two stacks. Starting Digipeater stops TNC/igate, node, linBPQ, Winlink RMS, FLDigi, and the rest.

---

## 2. Signal path

```
                 144.390 FM (US APRS)
                     |
              D700 DATA jack (6-pin mini-DIN)
                     |
            SignaLink USB (USB audio + VOX PTT)
                     |
                  Direwolf (digipeater)
                     |
        +------------+------------------+
        |            |                  |
   RF decode    Digipeat TX        WebChat / KISS
   (hear net)   (WIDE1-1 hop)      (messaging)
        |            |
        +-----+------+
              |
         SignaLink VOX → D700 TX
```

Tune and level the radio the same way as for igate. The digipeater adds **RF retransmit** of packets that ask for a hop.

---

## 3. Links that work with APRS Digipeater

Home page **switches** start services. Home page **links** open tools in a new tab. Digipeater-related links only make sense when **APRS Digipeater** is **green**.

### Related switches

| Switch | Role with Digipeater |
| --- | --- |
| **APRS Digipeater** | Must be **ON** — modem + RF digipeat |
| **APRS TNC/igate** | Leave **OFF** (exclusive with Digipeater) |
| **APRS HF TNC/igate** | Leave **OFF** (D700 is VHF FM) |
| **APRS WebChat** | Turn **ON after** Digipeater if you want the **Webchat** link |
| **APRS GPS Tracker** | Optional; needs a GPS receiver |

### Links that use the Digipeater modem

| Link | When it works | What it does |
| --- | --- | --- |
| **PacketLog** | **APRS Digipeater** green | Live Direwolf packet log. Shows decoded stations, digipeated traffic, and **audio average** (aim near **50**, usable ~10–90). Best proof the radio path and digi are alive. |
| **Webchat** | **APRS Digipeater** green **and** **APRS WebChat** green | Browser APRS messaging (APRSd) over the Digipeater’s KISS/TNC path. Send/receive APRS messages and beacons on RF. |
| **Audio** | Always available; use with Digipeater up | Mixer (**alsamixer**) for SignaLink **playback (TX)** and **capture (RX)**. Confirm levels in **PacketLog**, then **Save Configuration**. |
| **SysLog** | Always; use when a switch goes **red** | Service log — why Digipeater or WebChat failed (sound card busy, another modem still up, config error). |
| **AX.25** | Digipeater (or Node / TNC) provides a modem | Browser terminal for **LinPac** (`axcall.php`). For keyboard packet, tune to **packet simplex** (often 145.010 / 145.050), not APRS 144.390, unless you intend to chat on the APRS channel. Prefer **APRS TNC/igate** or **Node** for routine LinPac; Digipeater’s job is APRS hop service. |
| **Shell** | Always | Browser shell on the Pi (`sudo remount`, edits, `systemctl`). |
| **Bluetooth** | Pairing for phone apps | Pair a phone so **APRSDroid** (etc.) can use DigiPi as a wireless KISS TNC while Digipeater (or TNC/igate) is the active modem. |

### Useful external link (not on the DigiPi page)

| Link | What it does |
| --- | --- |
| [aprs.fi](https://aprs.fi) | Public APRS map. Useful to see traffic that reached the internet via *some* igate after your digi hop — Digipeater itself is primarily an **RF** helper, not a full **YOURCALL-2** igate upload path. |

### Link order for a normal Digipeater session

1. **APRS Digipeater** → ON (green). Leave **APRS TNC/igate** off.
2. **PacketLog** → confirm other stations decode; watch for digipeated hops; audio ~50.
3. Optional: **APRS WebChat** → ON, then **Webchat** to send a local message/beacon.
4. Optional: **Audio** to trim levels; **SysLog** if the Digipeater square turns red.

If **Webchat** does nothing: start **APRS Digipeater** first, then **APRS WebChat**, then open the **Webchat** link.

---

## 4. Bring it up (radio checklist)

1. **Radio** — D700 on **144.390 FM** (US), internal TNC **off**, APRS **off**, radio VOX **off**, menu **1-9-6 = 1200**, squelch just closed, low power.
2. **SignaLink** — **DLY** fully counterclockwise. **TX** ~9–10 o’clock. **RX** ~12 o’clock.
3. Dashboard — **APRS Digipeater** ON, then use the links in §3.

Only run a digipeater if your location and coordination make sense (fill a coverage gap; avoid stacking unnecessary hops on a busy channel).

---

## 5. Digipeater versus TNC/igate — which to pick

| Goal | Use |
| --- | --- |
| Help fill RF coverage / hop `WIDE1-1` | **APRS Digipeater** |
| Upload everything you hear to the internet (`YOURCALL-2` on aprs.fi) | **APRS TNC/igate** |
| Browser messaging + reliable APRS-IS presence | Usually **TNC/igate** + WebChat ([APRS-TNC-IGATE.md](APRS-TNC-IGATE.md)) |
| Both digipeat and full igate at once | Not on one SignaLink — pick one switch |

---

## 6. Under the hood

| Item | Path |
| --- | --- |
| Direwolf config | `/home/pi/direwolf.digipeater.conf` |
| Runtime copy | under `/run` (rebuilt every start) |
| Station identity | `/home/pi/localize.env` |
| systemd unit | `digipeater.service` |
| Log for PacketLog | Direwolf digipeater log |
| Front display | `direwatch.py` |

Stock DigiPi digipeater behavior (adjust in the conf to taste):

- Repeat **`WIDE1-1`** traffic on RF.
- Relay **message-type** packets from the internet to RF for nearby targets (~160 km).

```bash
sudo remount
sudo nano /home/pi/direwolf.digipeater.conf
```

Restart the switch (off, then on). Do not edit only the copy under `/run`.

After `sudo sed`, restore ownership if needed:

```bash
sudo chown pi:pi /home/pi/direwolf.digipeater.conf
```

---

## 7. Auto-start at boot

Switch positions do **not** survive reboot. To auto-start Digipeater:

```bash
sudo remount
sudo nano /etc/systemd/system/digipi-boot.service
```

Uncomment **one** modem line, for example:

```text
ExecStart=systemctl start digipeater
```

Leave **tnc**, **node**, **winlinkrms**, etc. commented — only one radio modem.

**Save Configuration** does not store switches; it saves the RAM overlay (audio, app files, logs). Use it after **Audio** changes.

---

## 8. Troubleshooting

| Symptom | Cause |
| --- | --- |
| Switch red | **SysLog** — another modem still up, or sound card busy |
| PacketLog idle, no decodes | Wrong jumpers/band/volume; radio TNC still on |
| Decodes but never digipeats | Path does not request `WIDE1-1` / digi alias; check `direwolf.digipeater.conf` |
| Radio stays keyed | SignaLink **DLY** not at minimum |
| Webchat link dead | Start **APRS Digipeater**, then **APRS WebChat**, then **Webchat** |
| Wanted map upload as YOURCALL-2 | Use **APRS TNC/igate**, not Digipeater |

---

## 9. Quick reference

| Item | Value |
| --- | --- |
| Frequency (US) | 144.390 MHz FM simplex |
| Baud | 1200 AFSK |
| Typical hop | `WIDE1-1` |
| Config | `/home/pi/direwolf.digipeater.conf` |
| Exclusive with | APRS TNC/igate, Node, linBPQ, Winlink RMS, … |
| Radio internal TNC | Off |
| SignaLink DLY | Fully CCW |
| PacketLog audio target | ~50 |
| Dashboard | http://digipi/ or http://10.0.0.5/ |
| Writable filesystem | `sudo remount` |

---

DigiPi is a collective-work image from KM6LYW Radio. This document describes using it; it does not redistribute the image.
