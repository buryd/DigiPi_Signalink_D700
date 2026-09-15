# DigiPi APRS TNC / IGate

What the **APRS TNC/igate** switch on the DigiPi home page actually does, how to bring it up on a **Kenwood TM-D700 + SignaLink USB**, and how to tell which half is broken when it misbehaves.

Hardware wiring, radio menus, and Initialize are in [PROCEDURE.md](PROCEDURE.md) §1–§8. This document assumes those are done.

---

## 1. Two jobs, one switch

The switch starts a single Direwolf process that does two unrelated things. Most confusion about DigiPi APRS comes from blaming one when the other is at fault.

| Half | What it is | Depends on |
| --- | --- | --- |
| **TNC** | Direwolf as a 1200-baud AFSK software modem on SignaLink USB audio | Radio, audio levels, jumpers |
| **IGate** | Decoded packets are forwarded to the APRS-IS internet network | Wi-Fi, callsign, APRS passcode |

The D700 stays an **analog FM radio**. Its built-in TNC must be **off** — DigiPi is the TNC. Two TNCs on one channel fight each other.

Because they are one process, the TNC can work perfectly while the igate fails, and the reverse. Section 5 tells them apart.

---

## 2. Signal path

```
                 144.390 FM
                     |
              D700 DATA jack (6-pin mini-DIN)
                     |
            SignaLink USB (USB audio + VOX PTT)
                     |
                  Direwolf
                     |
        +------------+-------------+
        |                          |
   RF decode                 WebChat / KISS
        |                          |
   APRS-IS upload            SignaLink VOX
   (YOURCALL-2)                    |
        |                     D700 keys TX
     aprs.fi
```

Receive needs no PTT. Transmit goes out because SignaLink hears TX audio and keys the radio itself. There is no CAT or serial PTT in this setup — that is why Initialize uses **USB Audio, GPIO12** and why GPIO12 is never actually wired.

---

## 3. What it is not

| Not this | Use instead |
| --- | --- |
| A digipeater. TNC/igate does **not** repeat `WIDE1-1` on RF. | **APRS Digipeater** switch (do not run both) |
| A firehose from the internet onto RF. Internet → RF is limited to nearby traffic and messages for local stations. | Nothing. This limit is deliberate and correct. |
| A GPS tracker. | **APRS GPS Tracker** switch (needs a GPS receiver) |
| An HF modem. 1200-baud AFSK is VHF FM only. | **APRS HF TNC/igate** (300 baud) |
| A packet BBS or node. | **AX.25 Node Network** or **AX.25 linBPQ** (§16) |

**One radio modem at a time.** Starting APRS TNC/igate stops the digipeater, node, linBPQ, Winlink RMS, FLDigi, and the rest. Direwolf cannot share one sound card between two stacks.

---

## 4. Bring it up

1. **Radio** — D700 on **144.390 FM** (APRS in the US), internal TNC **off**, APRS **off**, radio VOX **off**, menu **1-9-6 = 1200**, squelch just closed, low power to start.
2. **SignaLink** — **DLY** fully counterclockwise. **TX** around 9–10 o'clock. **RX** around 12 o'clock.
3. **Dashboard** — flip **APRS TNC/igate** on. The square turns green.
4. **PktLog** — watch for decodes from other stations. Audio average should land near **50** (usable range roughly 10–90).
5. **APRS WebChat** — flip on, then open the **Webchat** link to send a message or beacon.
6. **aprs.fi** — search your call. The igate appears as **YOURCALL-2**.

The bottom-row links (**Webchat**, **PktLog**, **Audio**, **SysLog**) only work while the matching switch is green.

### SSIDs

DigiPi gives each service its own SSID so they can coexist on the air without colliding.

| Service | Call |
| --- | --- |
| **APRS TNC/igate** | **YOURCALL-2** |
| AX.25 Node Network | YOURCALL-4 |
| linBPQ node | YOURCALL-7 |
| Winlink RMS | YOURCALL-10 |
| LinPac | YOURCALL (no SSID) |

---

## 5. Which half is broken

This is the single most useful table in this document.

| PktLog decodes? | On aprs.fi? | Conclusion |
| --- | --- | --- |
| Yes | Yes | Both halves working. |
| **Yes** | **No** | Radio path is fine. **IGate** problem: no internet, wrong callsign, or wrong APRS passcode. |
| **No** | No | **TNC** problem: audio, jumpers, frequency, or the radio's internal TNC is still on. |
| No | Yes (position only) | Your beacon is reaching APRS-IS over the internet, but you are deaf on RF. Still a TNC problem. |

A decode in PktLog proves the entire receive chain: antenna, radio, DATA jack, jumpers, SignaLink, USB audio, and the modem. If decodes appear, stop adjusting audio.

---

## 6. Beacons: RF versus internet

Direwolf distinguishes where a beacon goes.

| Config line | Where it goes |
| --- | --- |
| `PBEACON sendto=IG …` | APRS-IS only. Puts the igate on aprs.fi without transmitting. |
| `PBEACON …` (no `sendto`) | Transmitted on RF. |
| `TBEACON …` | Tracker beacon on RF. |

An igate at a fixed location normally beacons with `sendto=IG`. There is no reason to spend airtime telling the local channel about a station that never moves.

---

## 7. How it works under the hood

Useful when a config edit does not take effect.

| Item | Path |
| --- | --- |
| Direwolf config (editable) | `/home/pi/direwolf.tnc.conf` |
| Runtime copy | under `/run` — regenerated at every start |
| Station identity | `/home/pi/localize.env` (`NEWCALL`, `NEWGRID`, `NEWLAT`, `NEWLON`, `NEWAPRSPASS`) |
| systemd unit | `tnc.service` |
| Log feeding PktLog | Direwolf's log file |
| Front-panel display | `direwatch.py` |

Key config lines in `direwolf.tnc.conf`:

| Line | Purpose |
| --- | --- |
| `ADEVICE plughw:N,0 plughw:N,0` | Which sound card. `configure-signalink-d700.sh` points this at the SignaLink **USB Audio CODEC**. |
| `MYCALL YOURCALL-2` | Igate identity |
| `IGSERVER` | APRS-IS server |
| `IGLOGIN` | Callsign and APRS passcode |
| `PBEACON` / `TBEACON` | Beacons (§6) |

**The image is read-only.** To edit anything:

```bash
sudo remount
sudo nano /home/pi/direwolf.tnc.conf
```

Then restart the switch (off, then on). The runtime copy is rebuilt from the file in `/home/pi`, so editing the copy under `/run` accomplishes nothing.

If you edit with `sudo sed`, check ownership afterward:

```bash
sudo chown pi:pi /home/pi/direwolf.tnc.conf
```

`sudo sed -i` can leave the file `root:600`, which silently prevents Direwolf from staging it at startup.

---

## 8. Auto-start at boot

Switch positions **do not survive a reboot**. Stock `digipi-boot.service` starts nothing but the "Online" banner.

```bash
sudo remount
sudo nano /etc/systemd/system/digipi-boot.service
```

Uncomment exactly **one** `ExecStart=systemctl start …` line — `tnc` for this service. Leave the others commented; they are mutually exclusive.

**Save Configuration** does not store switch positions either. It copies the RAM overlay (audio mixer state, app files, logs) back to the SD card. Press it after changing **Audio** levels.

---

## 9. Troubleshooting

| Symptom | Cause |
| --- | --- |
| No USB sound card | SignaLink unplugged, cheap hub, or weak PSU. Use a Pi USB port directly. |
| SignaLink RX LED idle, no decodes | SPK jumper not on DATA pin 5; radio on the wrong band; volume too low; internal TNC still on. |
| Decodes are garbled or intermittent | RX level wrong. Target a PktLog audio average near 50. |
| TX audio present, radio never keys | SignaLink **TX** or Pi playback too low; Speaker muted in **Audio**; PTT jumper missing from pin 3. |
| Radio keys but nobody hears you | TX audio too low or overdriven; wrong TX band; CTCSS enabled on a simplex channel. |
| Radio stays keyed after a packet | SignaLink **DLY** is not at minimum. |
| Decodes fine, nothing on aprs.fi | IGate half. Check internet, `MYCALL`, and the APRS passcode. |
| Callsign missing a letter | Initialize truncated it. See [PROCEDURE.md](PROCEDURE.md) §14 for the full fix across every config. |
| Switch turns red | Open **SysLog**. Usually another radio service is still running, or Direwolf could not open the sound card. |
| Webchat link does nothing | **APRS WebChat** switch is off, or TNC/igate was never started first. |

---

## 10. Quick reference

| Item | Value |
| --- | --- |
| Frequency (US VHF APRS) | 144.390 MHz FM simplex |
| Baud / mode | 1200 AFSK |
| Igate call | YOURCALL-2 |
| Radio internal TNC | Off |
| Radio VOX | Off |
| SignaLink DLY | Fully counterclockwise |
| Target PktLog audio | ~50 |
| Dashboard | http://digipi/ or http://10.0.0.5/ |
| Make filesystem writable | `sudo remount` |

---

DigiPi is a collective-work image from KM6LYW Radio. This document describes using it; it does not redistribute the image.
