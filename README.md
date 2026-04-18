# AllTune2

A web-based control center for DVSwitch / AllStarLink systems.

AllTune2 provides one UI for:

- BrandMeister (BM)
- TGIF (through integrated HBLink)
- YSF
- AllStarLink
- EchoLink

The main goal of this project is simple:

- keep the backend reliable
- make switching between modes easier
- avoid fragile manual terminal work for normal use

---

## Current status

As of April 2026, these paths are working in the project:

- BrandMeister through the AllTune2 local BM/STFU-style helper path
- TGIF through the integrated HBLink helper path
- YSF through the normal DVSwitch path
- AllStarLink / EchoLink through Asterisk
- TGIF connect / disconnect / retune from the AllTune2 web UI

TGIF was the hardest part of this project.

The critical TGIF fix was:

- `LOOSE: True` in the `REPEATER-1` section of `tgif-hblink/hblink.cfg`
- dynamic `OPTIONS: StartRef=<TG>;RelinkTime=60` written by the helper when a TGIF talkgroup is selected

Do **not** hardcode a personal startup talkgroup into the public repo.

The public/safe design is:

- `hblink.cfg.example` keeps `LOOSE: True`
- `hblink.cfg.example` leaves `OPTIONS:` blank
- `set_hblink_tg.sh` writes the selected TG dynamically when the user connects from the UI

---

## Directory layout

Main project directory:

```text
/var/www/html/alltune2
```

Important subpaths:

```text
/var/www/html/alltune2/config.ini
/var/www/html/alltune2/public/
/var/www/html/alltune2/api/
/var/www/html/alltune2/tgif-hblink/
/var/www/html/alltune2/logs/
/var/www/html/alltune2/run/
```

Important TGIF/HBLink files:

```text
/var/www/html/alltune2/tgif-hblink/hblink.cfg
/var/www/html/alltune2/tgif-hblink/hblink.cfg.example
/var/www/html/alltune2/tgif-hblink/MMDVM_Bridge.hblink.ini
/var/www/html/alltune2/tgif-hblink/MMDVM_Bridge.hblink.ini.example
/var/www/html/alltune2/tgif-hblink/set_hblink_tg.sh
/var/www/html/alltune2/tgif-hblink/alltune2-hblink-audio-helper.sh
/var/www/html/alltune2/tgif-hblink/rules.py.template
```

External system files that must already exist and be sane:

```text
/opt/MMDVM_Bridge/MMDVM_Bridge.ini
/opt/MMDVM_Bridge/DVSwitch.ini
/opt/Analog_Bridge/Analog_Bridge.ini
```

---

## Requirements

- Debian 12 Bookworm or Debian 13 Trixie
- DVSwitch installed and basically working before AllTune2 is installed
- Asterisk / AllStarLink installed and working
- Analog_Bridge installed and working
- MMDVM_Bridge installed and working
- web server with PHP
- sudo access for setup and service control

AllTune2 is not meant to replace a broken base DVSwitch install. It assumes the radio/audio stack already works.

---

## Installation

For a brand-new install:

```bash
cd /var/www/html
git clone https://github.com/YOUR-ACCOUNT/alltune2.git
cd alltune2
sudo ./setup_alltune2.sh
```

After setup, review the local configuration files before trying the UI.

---

## Updating an existing installation

If AllTune2 is already installed, do not clone the repo again.

Use this process instead:

```bash
cd /var/www/html/alltune2
git pull origin main
sudo ./setup_alltune2.sh
```

Important notes for updates:

- `git pull` alone is not enough
- rerun `setup_alltune2.sh` after updates
- your local config files should be preserved
- do not overwrite your working live files with example files

Do not replace these live local files with repo example files unless you intentionally mean to rebuild them:

```text
/var/www/html/alltune2/config.ini
/var/www/html/alltune2/tgif-hblink/hblink.cfg
/var/www/html/alltune2/tgif-hblink/MMDVM_Bridge.hblink.ini
```

The setup script is intended to:

- validate required repo files
- preserve existing local config where possible
- prepare TGIF/HBLink support
- create missing example files if needed
- correct stale `hblink.cfg.example` files to `LOOSE: True`
- check permissions and syntax

---

## Required local configuration files

This is the part that matters most.

### 1) AllTune2 main app config

File:

```text
/var/www/html/alltune2/config.ini
```

At minimum, confirm these keys are correct for your node:

```ini
MYNODE=YOUR_ALLSTAR_NODE
DVSWITCH_NODE=YOUR_DVSWITCH_NODE
BM_SelfcarePassword=YOUR_BM_PASSWORD
TGIF_HotspotSecurityKey=YOUR_TGIF_SECURITY_KEY
```

What they are used for:

- `MYNODE` = your main local AllStar node
- `DVSWITCH_NODE` = the local node used for DVSwitch audio/linking
- `BM_SelfcarePassword` = BrandMeister helper/login control path
- `TGIF_HotspotSecurityKey` = TGIF/HBLink side authentication input used by the helper/config path

If `MYNODE` or `DVSWITCH_NODE` is wrong, the web UI may appear to work while the real audio/link path fails.

### 2) TGIF / HBLink live runtime config

File:

```text
/var/www/html/alltune2/tgif-hblink/hblink.cfg
```

This is the live TGIF/HBLink runtime file.

You must review:

- `CALLSIGN`
- `RADIO_ID`
- `PASSPHRASE`
- `MASTER_IP`
- `MASTER_PORT`
- `PORT`

For the TGIF `REPEATER-1` section, the important working values are:

```ini
[REPEATER-1]
MODE: PEER
ENABLED: True
LOOSE: True
IP:
PORT: 62034
MASTER_IP: tgif.network
MASTER_PORT: 62031
OPTIONS:
```

Important notes:

- `LOOSE: True` is required for proper inbound TGIF audio behavior in this project
- `OPTIONS:` should not be permanently hardcoded to your personal TG in the public repo
- the helper script writes `StartRef=<TG>;RelinkTime=60` dynamically when the user connects or retunes TGIF
- after a live TGIF connect, the runtime `hblink.cfg` will no longer remain blank on `OPTIONS:` because the helper updates it

If `LOOSE` is false, TGIF may appear to half-work or pass packets without proper usable inbound audio.

### 3) TGIF / HBLink example config

File:

```text
/var/www/html/alltune2/tgif-hblink/hblink.cfg.example
```

This is the repo-safe example file.

This file should be generic and sanitized.

Safe public behavior:

```ini
LOOSE: True
OPTIONS:
```

Do not publish:

- your real passphrase
- your real callsign if you want the example generic
- your real radio ID if you want the example generic
- your personal startup TG

The helper fills in the runtime TG dynamically.

### 4) Local HBLink-side MMDVM bridge file

File:

```text
/var/www/html/alltune2/tgif-hblink/MMDVM_Bridge.hblink.ini
```

This file is the local bridge between HBLink and the node’s MMDVM/Analog_Bridge side.

The key working values are:

```ini
[DMR Network]
Enable=1
Address=127.0.0.1
Port=62033
Local=62032
Password=homebrew
Slot1=0
Slot2=1
```

These must match the `MASTER-1` section in `hblink.cfg`.

In this project, the working relationship is:

- `hblink.cfg` `MASTER-1` listens on `62033`
- `MMDVM_Bridge.hblink.ini` points to `127.0.0.1:62033`
- local side uses `62032`
- password must match (`homebrew` in the working project layout)

If these values do not match, TGIF/HBLink will not pass audio correctly.

### 5) External system `MMDVM_Bridge.ini`

File:

```text
/opt/MMDVM_Bridge/MMDVM_Bridge.ini
```

This is part of the normal DVSwitch system stack.

AllTune2 does not replace your need for a sane base DVSwitch configuration.

You should verify at minimum:

- your normal DMR/DVSwitch settings are correct
- your local ports do not conflict with the HBLink side files
- your existing DVSwitch path still works before you start blaming AllTune2

This file matters especially for:

- BM path
- YSF path
- general DMR runtime behavior outside the dedicated TGIF HBLink sidecar path

### 6) External system `DVSwitch.ini`

File:

```text
/opt/MMDVM_Bridge/DVSwitch.ini
```

This file must also already be valid.

It affects the wider DVSwitch stack and mode changes.

If DVSwitch itself is not configured correctly, AllTune2 may show misleading state while the underlying audio/link chain is wrong.

### 7) External system `Analog_Bridge.ini`

File:

```text
/opt/Analog_Bridge/Analog_Bridge.ini
```

This file is extremely important.

It controls the local audio side used by this project.

At minimum, verify:

- the service is installed and running
- the local TG value is sane
- the audio and TLV side match your working DVSwitch layout

This project also benefited from these audio-related adjustments during testing:

```ini
usrpAudio = AUDIO_UNITY
usrpGain = 1.35
```

Those values were used to reduce loud click/pop behavior while keeping audio usable.

If Analog_Bridge is not running correctly, TGIF may log activity but you still will not hear good local audio.

---

## How TGIF works in AllTune2

TGIF is handled differently from BM and YSF.

The TGIF path uses:

- `api/connect.php`
- `tgif-hblink/alltune2-hblink-audio-helper.sh`
- `tgif-hblink/set_hblink_tg.sh`
- `tgif-hblink/hblink.cfg`
- `tgif-hblink/MMDVM_Bridge.hblink.ini`
- `tgif-hblink/rules.py`

When the user selects TGIF from the web UI:

- the UI calls the helper
- the helper starts or retunes HBLink
- `set_hblink_tg.sh` updates:
  - `rules.py`
  - `hblink.cfg OPTIONS:`
  - `hblink.cfg LOOSE: True`
- the local DVSwitch/AllStar audio link is reloaded
- TGIF audio is bridged through the local HBLink path

The important design choice is that the startup TG is dynamic, not hardcoded in the public repo.

---

## Safe public defaults

These are the recommended public repo defaults.

### `hblink.cfg.example`

Keep this generic:

```ini
LOOSE: True
OPTIONS:
```

### `set_hblink_tg.sh`

This script should:

- force `LOOSE: True`
- write `OPTIONS: StartRef=<TG>;RelinkTime=60`

Do not hardcode:

- your personal TG like `19570`
- someone else’s preferred startup TG like `4000`
- your real TGIF passphrase
- your BM password
- your node-specific live config

---

## Web UI path

The TGIF web UI path is in:

```text
/var/www/html/alltune2/api/connect.php
```

The working behavior is:

- if TGIF is already active, `tune()` is used
- if TGIF is not active, `start()` is used
- the local DVSwitch audio link is reloaded after TGIF start/tune
- the UI session state is updated to show TGIF as active

This part was already wired correctly.

The real fix was in the HBLink runtime behavior, not the basic UI call path.

---

## Testing checklist

After configuration, open the UI:

```text
http://YOUR-NODE-IP/alltune2/public/
```

Recommended tests:

### BrandMeister
- connect to BM
- confirm audio both ways
- retune to another TG without disconnecting first

### TGIF
- connect to TGIF from the web UI
- confirm audio both ways on a known active TG
- retune from the web UI to another known active TG
- confirm `set_hblink_tg.sh` updates the runtime config correctly

### YSF
- connect to a known YSF target
- confirm audio and clean mode switching

### Mode switching
Test switching between:

- BM → TGIF
- TGIF → BM
- YSF → TGIF
- TGIF → YSF
- Disconnect DVSwitch
- Disconnect All

Do not trust logs alone. Real audio is the final test.

---

## Security and GitHub safety

Never commit live secrets.

Do not track these live files with real values:

- `config.ini`
- `tgif-hblink/hblink.cfg`
- `tgif-hblink/MMDVM_Bridge.hblink.ini`
- backup files like `*.bak`
- ad-hoc copied system configs with real secrets

If secrets were ever exposed in past commits or shared files, rotate them before making the repo public again.

Recommended rotations if exposed:

- TGIF hotspot security key / passphrase
- BrandMeister password or key
- any other service credential that was copied into the repo or a shared file

History cleanup helps, but rotation is still the safe move.

---

## What to commit from the TGIF fix

The minimal repo-side fix from this work is:

- `tgif-hblink/hblink.cfg.example`
- `tgif-hblink/set_hblink_tg.sh`
- `setup_alltune2.sh`
- `.gitignore`

Be careful not to commit:

- live `hblink.cfg`
- live `MMDVM_Bridge.hblink.ini`
- `DVSwitch.ini` copies in the project tree
- `dmr_utils3/` if it is only a local unpacked dependency tree and not intended as tracked source
- temporary backup files such as:
  - `hblink.cfg.before-step1`
  - `set_hblink_tg.sh.before-step5`

---

## Troubleshooting notes

### TGIF works one-way or no-way

Check these first:

- `hblink.cfg` has `LOOSE: True`
- `set_hblink_tg.sh` is writing:
  - `OPTIONS: StartRef=<TG>;RelinkTime=60`
- `MMDVM_Bridge.hblink.ini` still points to:
  - `Address=127.0.0.1`
  - `Port=62033`
  - `Local=62032`
  - `Password=homebrew`
- `Analog_Bridge` is active
- the TG you are testing is actually active

### Parrot works but normal TG does not

That usually means the TGIF/HBLink side is only partially working. Check `LOOSE` and dynamic `OPTIONS` first.

### UI says connected but audio is wrong

Verify the real backend state, not only the UI state:

- helper status
- HBLink logs
- actual audible receive/transmit audio

---

## Final notes

This project has several backend paths and can look simple from the browser while doing a lot underneath.

The safest way to work on it is:

- one file at a time
- keep the original live system protected
- make only minimal changes
- test real audio, not just log output

---

## License

Provided as-is for amateur radio use.
