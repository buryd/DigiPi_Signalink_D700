# DigiPi on Raspberry Pi 3B+ with SignaLink USB and Kenwood TM-D700

This procedure installs [DigiPi](https://digipi.org) (KM6LYW) on a **Raspberry Pi 3B+** and interfaces it to a **Kenwood TM-D700 / TM-D700A** through a **Tigertronics SignaLink USB**.

DigiPi is a ready-made Raspberry Pi image. You do not compile it. You flash it, initialize it, then apply SignaLink audio settings.

The helper scripts in this folder automate the SD-card flash and the on-Pi SignaLink configuration. They do **not** download the DigiPi image. That image is distributed to [KM6LYW Patreon](https://www.patreon.com/km6lyw) supporters.

---

## 1. Parts

| Item | Notes |
| --- | --- |
| Raspberry Pi 3B+ | Supported. Avoid original Pi Zero / Pi 2 / 3A (single-core). |
| Official 5 V / 2.5 A+ PSU | Undervoltage drops USB audio and causes decode errors. |
| microSD card | 8 GB or larger, Class 10 / A1. |
| SignaLink USB | USB audio + VOX PTT. |
| Cable **SLCAB6PM** (or combo **SLUSB6PM**) | 6-pin mini-DIN to the D700 **DATA** jack. |
| Jumper module **SLMOD6PM** | Or four jumper wires (see below). |
| Kenwood TM-D700 / TM-D700A | DATA jack is a 6-pin mini-DIN on the **radio body**, not the mic. |
| DigiPi image | Current line: **v2.2-1** (Sept 2026). Download from Patreon, do not redistribute. |

Do **not** use the D700 microphone jack for this setup. Use the DATA port.

---

## 2. SignaLink jumpers (TM-D700 DATA port)

Easiest path: plug in **SLMOD6PM**. That module is listed for TM-D700 / TM-D700A.

If you are wiring JP1 yourself (1200 baud APRS / packet):

```
SignaLink JP1          D700 DATA pin     Signal
------------------------------------------------
MIC  ----------------> Pin 1            PKD  (TX audio in)
GND  ----------------> Pin 2            Ground
PTT  ----------------> Pin 3            PKS  (PTT)
SPK  ----------------> Pin 5            PR1  (1200 baud RX audio)
```

Leave pin 4 and pin 6 unjumpered for 1200 baud.

| D700 DATA pin | Name | Use |
| --- | --- | --- |
| 1 | PKD | Packet TX audio into the radio |
| 2 | GND | Ground |
| 3 | PKS | PTT (SignaLink grounds this to key TX) |
| 4 | PR9 | 9600 baud discriminator audio |
| 5 | PR1 | 1200 baud RX audio (use this for APRS) |
| 6 | SQC | Squelch output (not used by SignaLink) |

For VARA FM Wide / 9600-style audio only: move **SPK** from pin 5 to **pin 4**, and set radio menu **1-9-6** to 9600. Default for DigiPi APRS is **1200**.

### SignaLink front-panel knobs

| Knob | Starting point |
| --- | --- |
| **TX** | About 9–10 o’clock. Raise until the radio shows RF, then back off until the signal is clean (not overdriven). |
| **RX** | About 12 o’clock. Fine-tune from DigiPi **Audio** / Direwolf levels. |
| **DLY** | Fully counterclockwise (minimum). SignaLink VOX must drop PTT quickly after tones stop. |

The D700 radio **VOX must be OFF**. SignaLink provides its own VOX.

---

## 3. Kenwood TM-D700 radio setup

Power the radio off while plugging the 6-pin DATA cable.

1. Turn the radio on.
2. Press **TNC** until the built-in TNC is **off** (TNC icon gone). DigiPi/Direwolf is the TNC.
3. Turn **APRS** off on the radio so the built-in tracker does not fight Direwolf.
4. Menu **1-9-6 DATA SPEED** → **1200 bps**.
5. Menu **1-6-1 DATA BAND** is only for the **internal** TNC. With SignaLink, packet follows the **TX band**. Select the band you will use and set that VFO/memory to the packet frequency.
6. Radio VOX: **OFF**.
7. CTCSS / DCS: **OFF** on the packet channel (APRS is simplex).
8. Start at **low power** (5 W) until levels are confirmed.

US APRS: **144.390 MHz** FM. Europe: **144.800 MHz** FM.

---

## 4. Flash DigiPi (Windows)

### Option A — helper script (recommended)

1. Put the DigiPi `.zip` or `.img` in this folder, or pass `-Image`.
2. Insert a blank microSD (USB reader).
3. Right-click `install-digipi.bat` → **Run as administrator**.

The script lists removable disks, flashes the image, and copies `configure-signalink-d700.sh` onto the DigiPi boot partition.

### Option B — Raspberry Pi Imager / Balena Etcher

1. Unzip the DigiPi download if the tool requires a `.img`.
2. Flash the image to the microSD. An 8 GB card is enough.
3. After flash, copy `scripts/configure-signalink-d700.sh` onto the FAT **boot** partition.

Official flash notes: [digipi.org](https://digipi.org).

---

## 5. First boot and Wi-Fi

1. Insert the card in the Pi 3B+. Plug in the SignaLink USB. Apply power.
2. Wait for the **DigiPi** Wi-Fi hotspot.
3. Join it. Password: `abcdefghij`
4. Browse to **http://10.0.0.5/** → **Wifi**.
5. Enter home SSID and password. Reboot.
6. On your LAN, open **http://digipi/** or **http://digipi.local/**.
   - If DNS fails, use the Pi’s DHCP address from the router.
   - If the hotspot is still up, home Wi-Fi did not take. Recheck SSID/password.

Default SSH user: `pi` / `raspberry`.

---

## 6. Initialize DigiPi for SignaLink

On http://digipi/ click **Initialize**.

| Field | Value for this station |
| --- | --- |
| Callsign / passwords / grid | Yours. Initialize once; later edits go in `/home/pi/localize.env`. |
| Radio interface | **USB Audio, GPIO12** |

SignaLink is USB audio with **internal VOX**. There is no CAT PTT. KM6LYW’s guidance is to pick **USB Audio, GPIO12**. GPIO12 is unused; SignaLink keys the D700 when it hears TX audio.

Click **Initialize**, then **Reboot**. The Pi returns to read-only “firmware” mode.

---

## 7. On-Pi SignaLink configuration

SSH in, or use the DigiPi **Shell** page:

```bash
sudo remount
sudo cp /boot/configure-signalink-d700.sh /home/pi/ 2>/dev/null || \
  sudo cp /boot/firmware/configure-signalink-d700.sh /home/pi/
chmod +x /home/pi/configure-signalink-d700.sh
sudo /home/pi/configure-signalink-d700.sh
```

If the script was not copied to boot, copy it from this repo over SCP.

The script:

- remounts the DigiPi filesystem read-write
- finds the SignaLink **USB Audio CODEC**
- makes it the default ALSA device
- raises playback (TX) so SignaLink VOX keys
- sets capture (RX) to a sane start point
- points Direwolf `ADEVICE` at the USB card
- saves mixer state

Then reboot from the DigiPi home page.

---

## 8. Audio levels

On http://digipi/ open **Audio**:

- Playback / Speaker → TX into SignaLink (often 70–90%). Too low = no PTT. Too high = dirty FM.
- Capture (press F4 in alsamixer) → RX. Direwolf **PktLog** average should land near **50** (range 10–90).

If the SignaLink PTT LED never lights: raise Pi playback **and** the SignaLink **TX** knob.

---

## 9. Verify

1. D700 on 144.390 (or local APRS), squelch just closed, low power.
2. SignaLink USB LED on; RX LED flickers with local packets.
3. DigiPi home page: start **APRS IGate** or **Digipeater**.
4. **PktLog** should decode other stations.
5. Send a test from **APRS WebChat**. SignaLink PTT LED and D700 TX should key, then drop quickly (DLY at minimum).
6. Check [aprs.fi](https://aprs.fi) for your call.

---

## 10. Defaults and useful URLs

| Item | Value |
| --- | --- |
| Hotspot SSID / password | `DigiPi` / `abcdefghij` |
| Hotspot URL | http://10.0.0.5/ |
| LAN URL | http://digipi/ or http://digipi.local/ |
| SSH | `pi` / `raspberry` |
| VNC | `digipi:5901` password `test11` |
| Make filesystem writable | `sudo remount` |
| After-init edits | `/home/pi/localize.env` |

Community: [DigiPi Google Group](https://groups.google.com/g/digipi) · [Discord](https://discord.gg/3X9bMjjwxw)

---

## 11. Troubleshooting

| Symptom | Likely cause |
| --- | --- |
| No USB sound card | SignaLink unplugged, cheap hub, or weak PSU. Use a Pi USB port directly. |
| RX LED idle, no decodes | SPK jumper not on pin 5; radio on wrong band; volume too low; internal TNC still on. |
| TX audio, radio never keys | DLY/TX too low; Pi Speaker muted; jumpers missing PTT pin 3. |
| Radio keys but no RF / no path | TX audio too low or too high; radio not on TX band; frequency/CTCSS. |
| Radio stays keyed | SignaLink **DLY** not at minimum. |
| Hotspot never appears | Bad flash, wrong Pi model, or insufficient power. |
| Init already used | Edit `/home/pi/localize.env` after `sudo remount`. |

---

## License note

DigiPi is a collective-work image from KM6LYW Radio. These helper scripts do not include that image. Share the scripts; do not post the DigiPi image online.
