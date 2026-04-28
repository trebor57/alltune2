# 🚀 AllTune2

## One Dashboard. All Your Networks.

✅ Optimized for Debian 12 & 13 on 64-bit ARM (Raspberry Pi 4, 5)

AllTune2 is a modern control panel for **AllStarLink 3 + DVSwitch**.

It gives you one place to work with:

- BrandMeister
- TGIF
- YSF
- D-Star
- P25
- NXDN
- AllStarLink
- EchoLink
- Local Monitor
- Transceiver
- Favorites
- Live status and activity

Simple. Clean. Powerful.

## ✨ WHAT ALLTUNE2 CAN DO

AllTune2 is meant to be a one-screen radio control center.

With it, you can:

- connect to BrandMeister talkgroups
- connect to TGIF talkgroups
- connect to YSF reflectors / rooms
- connect to D-Star reflectors when D-Star is configured
- connect to P25 reflectors / talkgroups when P25 is configured
- connect to NXDN reflectors / talkgroups when NXDN is configured
- connect to AllStarLink nodes
- connect to EchoLink nodes
- use Local Monitor
- use Transceiver
- save and use Favorites
- use manual entry
- watch live status and activity
- use audio alerts if enabled

Some local functions can also be used alongside BM, TGIF, YSF, D-Star, P25, or NXDN operation depending on your setup and workflow.

## Live keyed activity highlighting

AllTune2 now shows live keyed/activity highlighting for linked AllStarLink / EchoLink node rows and supported managed DVSwitch modes.

What it does:
- highlights the active linked node row when live activity is detected
- shows keyed/activity feedback for supported managed modes such as D-Star, P25, and NXDN when configured
- uses a softer amber accent so the active row stands out without overpowering the dashboard
- keeps the existing connection logic unchanged

Notes:
- this is a visual/status enhancement
- it does not change TGIF, BrandMeister, YSF, D-Star, P25, NXDN, AllStarLink, or EchoLink connect/disconnect behavior
- active row highlighting depends on live activity/status data being available from the node

## ⚠️ BEFORE YOU INSTALL

You MUST already have:

- Working AllStarLink 3 (ASL3)
- Working DVSwitch
- Analog_Bridge running
- MMDVM_Bridge running

Optional modes such as D-Star, P25, and NXDN require those modes to already work in your ASL3 / DVSwitch / MMDVM_Bridge setup before enabling them in AllTune2.

If your node is not already working, fix that first.

AllTune2 sits on top of a working base system.  
It is not meant to repair a broken base install.

## 📥 INSTALL (FIRST TIME)

Use these commands only for a brand-new install:

```bash
cd /var/www/html
git clone https://github.com/TerryClaiborne/alltune2.git
cd alltune2
sudo ./setup_alltune2.sh
```
**Note:** `setup_alltune2.sh` may pause for a short time during dependency checks and TGIF/HBLink environment setup, especially on slower systems such as a Pi3. This is normal. Wait for the final setup summary before assuming the installer is stuck or stopping it early.

### What the setup script does

The setup script helps by:

- setting permissions
- building the TGIF / HBLink backend
- installing requirements
- creating config files if missing
- preserving existing config files
- refreshing helper files

The setup script is mainly for install/setup/system-level refresh work.  
It is not required for every code-only GitHub update.

## 🔁 UPDATE / REINSTALL / REBOOT

There are now **two** different update paths.

### A) NORMAL CODE-ONLY UPDATE

Use this when the GitHub update only changes app code, helper scripts, Python files, PHP files, CSS/JS, or README content.

```bash
cd /var/www/html/alltune2
git pull origin main
```

In many cases, that is enough.

### B) UPDATE THAT NEEDS SETUP

Use this when the update includes install/setup changes such as:

- `setup_alltune2.sh` changes
- new sudoers requirements
- new permissions requirements
- new service / system integration changes
- new config template handling

```bash
cd /var/www/html/alltune2
git pull origin main
sudo ./setup_alltune2.sh
```

### C) REBOOT WHEN NEEDED

Some updates change a runtime process that may already be running in memory.

Examples:

- HBLink `bridge.py` changes
- logging behavior changes
- long-running helper/runtime behavior

For those updates, rebooting once after the update is recommended so the old running process is fully cleared and the new code starts clean.

### Important

Do **not** assume every update needs `setup_alltune2.sh`.

For normal code-only updates, `git pull` may be enough.

Run `setup_alltune2.sh` when the update includes install, permissions, sudoers, service, or other system-level setup changes.

If the update changes a long-running TGIF / HBLink runtime process, a reboot once after updating is recommended.

## ✏️ FILES YOU MUST EDIT

### 1. Main Config

`/var/www/html/alltune2/config.ini`

Example:

```ini
MYNODE="YOUR NODE"
DVSWITCH_NODE="YOUR DVSWITCH NODE"
BM_SelfcarePassword="CHANGE_ME"
TGIF_HotspotSecurityKey="CHANGE_ME"
DSTAR_ENABLED=0
P25_ENABLED=0
NXDN_ENABLED=0
```

#### What these mean

**MYNODE**  
Your AllStar node number.

Example:

```text
MYNODE=67040
```

**DVSWITCH_NODE**  
Your DVSwitch node number.

Most systems use `1999` or `1998`.

Example:

```text
DVSWITCH_NODE=1999
```

**BM_SelfcarePassword**  
Your BrandMeister SelfCare password.

**TGIF_HotspotSecurityKey**  
Your TGIF Hotspot Security Key.

This is **NOT** your TGIF website login password.

**DSTAR_ENABLED**  
Controls whether D-Star appears as a usable mode in AllTune2.

Use:

```ini
DSTAR_ENABLED=0
```

to keep D-Star disabled.

Use:

```ini
DSTAR_ENABLED=1
```

only after D-Star already works on your ASL3 / DVSwitch / MMDVM_Bridge system.

When D-Star is disabled or not configured, the D-Star Live Status box remains idle, and D-Star is not available in the main dropdown or Favorites.

**P25_ENABLED** and **NXDN_ENABLED**  
Control whether P25 and NXDN appear as usable modes in AllTune2.

Leave them disabled unless those modes already work on your ASL3 / DVSwitch / MMDVM_Bridge system:

```ini
P25_ENABLED=0
NXDN_ENABLED=0
```

Enable them only after testing the underlying DVSwitch mode from the terminal:

```ini
P25_ENABLED=1
NXDN_ENABLED=1
```

When P25 or NXDN is disabled or not configured, that mode is not available in the main dropdown or Favorites. The Live Status box can remain visible, but it will stay Idle.

### 2. D-Star Setup

D-Star is optional.

Before enabling D-Star in AllTune2, D-Star should already work from the ASL3 / DVSwitch / MMDVM_Bridge side.

A basic manual test looks like this:

```bash
/opt/MMDVM_Bridge/dvswitch.sh mode DSTAR
/opt/MMDVM_Bridge/dvswitch.sh tune REF030EL
```

To disconnect D-Star manually:

```bash
/opt/MMDVM_Bridge/dvswitch.sh tune 4000#
```

AllTune2 does not create your D-Star account, registration, reflector setup, or system-level MMDVM_Bridge D-Star configuration.

Enable D-Star in AllTune2 only after your system D-Star path is already working:

```ini
DSTAR_ENABLED=1
```

If D-Star is not configured, leave it disabled:

```ini
DSTAR_ENABLED=0
```

### 3. P25 and NXDN Setup

P25 and NXDN are optional.

Before enabling P25 or NXDN in AllTune2, each mode should already work from the ASL3 / DVSwitch / MMDVM_Bridge side.

Basic manual tests look like this:

```bash
/opt/MMDVM_Bridge/dvswitch.sh mode P25
/opt/MMDVM_Bridge/dvswitch.sh tune YOUR_P25_TARGET
```

```bash
/opt/MMDVM_Bridge/dvswitch.sh mode NXDN
/opt/MMDVM_Bridge/dvswitch.sh tune YOUR_NXDN_TARGET
```

For P25 and NXDN, the manual stop / return-to-idle sequence is:

```bash
/opt/MMDVM_Bridge/dvswitch.sh tune 0
sleep 2
/opt/MMDVM_Bridge/dvswitch.sh mode DMR
```

AllTune2 uses that same basic cleanup idea for P25 and NXDN disconnect handling.

AllTune2 does not create or repair your P25 or NXDN system-level setup. Enable these modes only after they already work from the terminal:

```ini
P25_ENABLED=1
NXDN_ENABLED=1
```

If P25 or NXDN is not configured, leave it disabled:

```ini
P25_ENABLED=0
NXDN_ENABLED=0
```

### 4. TGIF Config

`/var/www/html/alltune2/tgif-hblink/hblink.cfg`

Look in the `[REPEATER-1]` section.

Example:

```ini
PASSPHRASE: your_tgif_key
CALLSIGN: YOURCALL
RADIO_ID: 330000812
OPTIONS: StartRef=19750;RelinkTime=60
```

#### What these mean

**PASSPHRASE**  
Your TGIF Hotspot Security Key.

This is **NOT** your TGIF login password.

**CALLSIGN**  
Your ham callsign.

Example:

```text
CALLSIGN: KC3KMV
```

**RADIO_ID**  
Your DMR / BrandMeister Hotspot ID + 1

This part is very important.

Real example:

```text
Your hotspot ID: 330000811
Use:             330000812
```

Another example:

```text
Your hotspot ID: 3101234
Use:             3101235
```

Do **NOT** use your original hotspot ID unchanged.

**OPTIONS**  
Optional startup TGIF talkgroup.

Example:

```text
StartRef=19750;RelinkTime=60
```

If you want TGIF to start on a certain talkgroup, that is where you set it.

### 5. Review This File

`/var/www/html/alltune2/tgif-hblink/MMDVM_Bridge.hblink.ini`

Example:

```ini
Callsign=YOURCALL
Id=330000812
```

#### What these mean

**Callsign**  
Your ham callsign.

Example:

```text
Callsign=KC3KMV
```

**Id**  
Your DMR / BrandMeister Hotspot ID + 1

Real example:

```text
Your hotspot ID: 330000811
Use:             330000812
```

Do **NOT** use your original hotspot ID unchanged.

#### Optional values

Most users can leave these as `0`:

```ini
RXFrequency=0
TXFrequency=0
```

These only matter if you run a repeater.

If you do not run a repeater, leaving them at `0` is fine and has no effect on normal operation.

## 🚫 DO NOT EDIT THESE UNLESS YOU ALREADY KNOW WHY

These files must already be working correctly on your system:

- `/opt/MMDVM_Bridge/DVSwitch.ini`
- `/opt/MMDVM_Bridge/MMDVM_Bridge.ini`
- `/opt/Analog_Bridge/Analog_Bridge.ini`

If those files are broken, AllTune2 will not work correctly.

For D-Star, P25, and NXDN, the required account / registration / reflector / mode configuration must already be correct in the underlying DVSwitch / MMDVM_Bridge setup before enabling those modes in AllTune2.

## 🌐 OPEN ALLTUNE2 IN YOUR BROWSER

Once AllTune2 is installed and configured, open it in your web browser.

Example:

```text
http://192.168.1.120/alltune2/public/
```

The full path also works:

```text
http://192.168.1.120/alltune2/public/index.php
```

Replace `192.168.1.120` with the IP address or hostname of your own node.

The shorter `/public/` address is usually easier and works fine.

## 🖥️ HOW TO USE ALLTUNE2

Once AllTune2 is installed and configured, open it in your browser and use the control center.

Basic idea:

- choose the network or mode
- enter a target or choose a Favorite
- press Connect
- watch the status / activity area
- press Disconnect when done

## 🔵 BRANDMEISTER

Use BrandMeister when you want to connect to a BM talkgroup.

### Typical BM workflow

- choose BrandMeister
- enter the talkgroup number
- press Connect
- wait for the status to show the connection
- use Disconnect when you want to leave

### BM talkgroup changes

BrandMeister is usually one of the faster paths.

If you want to change from one BM talkgroup to another:

- enter the new talkgroup
- press Connect again

## 🟢 TGIF

Use TGIF when you want to connect to a TGIF talkgroup.

### Typical TGIF workflow

- choose TGIF
- enter the talkgroup number
- press Connect
- wait for the TGIF path to come up
- watch status / activity for confirmation
- use Disconnect when finished

### Important TGIF note

TGIF may take a little longer to connect than BrandMeister.

That is normal.

You can also stay connected to BM, TGIF, YSF, D-Star, P25, or NXDN and add AllStarLink nodes or EchoLink nodes using Transceive or Local Monitor, depending on your setup and workflow.

## 🟡 YSF

Use YSF when you want to connect to a YSF room or reflector.

### Typical YSF workflow

- choose YSF
- enter the YSF target you want
- press Connect
- watch the status area
- use Disconnect when done

## 🟠 D-STAR

Use D-Star when you want to connect to a D-Star reflector.

D-Star is optional and must already be working in your ASL3 / DVSwitch / MMDVM_Bridge system before AllTune2 can control it.

### Typical D-Star workflow

- make sure `DSTAR_ENABLED=1` is set in `/var/www/html/alltune2/config.ini`
- choose D-Star
- enter the D-Star target, such as `REF030EL`
- press Connect
- watch the status area
- use Disconnect or Disconnect DVSwitch when done

### Important D-Star notes

D-Star uses the managed DVSwitch path, similar to YSF.

AllTune2 runs the DVSwitch D-Star mode and tune commands, then uses the configured private DVSwitch audio node.

D-Star disconnect uses:

```bash
/opt/MMDVM_Bridge/dvswitch.sh tune 4000#
```

If D-Star is not enabled or not available, it will not appear in the main mode dropdown or Favorites. The D-Star Live Status box may still be visible, but it will remain Idle.

## 🟤 P25

Use P25 when you want to connect to a P25 target supported by your DVSwitch / MMDVM_Bridge setup.

P25 is optional and must already be working in your ASL3 / DVSwitch / MMDVM_Bridge system before AllTune2 can control it.

### Typical P25 workflow

- make sure `P25_ENABLED=1` is set in `/var/www/html/alltune2/config.ini`
- choose P25
- enter the P25 target
- press Connect
- watch the status area
- use Disconnect or Disconnect DVSwitch when done

### Important P25 notes

P25 uses the managed DVSwitch path.

AllTune2 runs the DVSwitch P25 mode and tune commands, then uses the configured private DVSwitch audio node.

P25 disconnect uses a cleanup sequence that tunes to `0`, waits briefly, and returns the bridge to DMR mode:

```bash
/opt/MMDVM_Bridge/dvswitch.sh tune 0
sleep 2
/opt/MMDVM_Bridge/dvswitch.sh mode DMR
```

If P25 is not enabled or not available, it will not appear in the main mode dropdown or Favorites. The P25 Live Status box may still be visible, but it will remain Idle.

## ⚫ NXDN

Use NXDN when you want to connect to an NXDN target supported by your DVSwitch / MMDVM_Bridge setup.

NXDN is optional and must already be working in your ASL3 / DVSwitch / MMDVM_Bridge system before AllTune2 can control it.

### Typical NXDN workflow

- make sure `NXDN_ENABLED=1` is set in `/var/www/html/alltune2/config.ini`
- choose NXDN
- enter the NXDN target
- press Connect
- watch the status area
- use Disconnect or Disconnect DVSwitch when done

### Important NXDN notes

NXDN uses the managed DVSwitch path.

AllTune2 runs the DVSwitch NXDN mode and tune commands, then uses the configured private DVSwitch audio node.

NXDN disconnect uses a cleanup sequence that tunes to `0`, waits briefly, and returns the bridge to DMR mode:

```bash
/opt/MMDVM_Bridge/dvswitch.sh tune 0
sleep 2
/opt/MMDVM_Bridge/dvswitch.sh mode DMR
```

If NXDN is not enabled or not available, it will not appear in the main mode dropdown or Favorites. The NXDN Live Status box may still be visible, but it will remain Idle.


## 🔴 ALLSTARLINK

Use AllStarLink when you want to work with AllStar nodes directly.

### Typical AllStarLink workflow

- choose AllStarLink
- enter the node number you want
- press Connect
- watch the live status / activity
- disconnect when finished

AllStarLink mode is useful for:

- direct node linking
- node monitoring
- local AllStar activity

## 🟣 ECHOLINK

Use EchoLink when you want to connect to an EchoLink node.

### Typical EchoLink workflow

- choose EchoLink
- enter the EchoLink node number
- press Connect
- watch status for confirmation
- disconnect when done

## 🎧 LOCAL MONITOR

Local Monitor is there for local monitoring use.

That means it can be used when you want to:

- listen locally
- monitor what is happening on the node
- work in a more local / direct way

## 🎙️ TRANSCEIVER

Transceiver mode is there for direct radio-side operation.

In simple terms:

- Local Monitor is for local listening / monitoring
- Transceiver is for direct local radio operation

These are local functions, not just network destination fields.

## ⭐ FAVORITES

Favorites help save time.

Use Favorites when you have:

- a BM talkgroup you use often
- a TGIF talkgroup you use often
- a YSF room you use often
- a D-Star reflector you use often, if D-Star is enabled
- a P25 target you use often, if P25 is enabled
- an NXDN target you use often, if NXDN is enabled
- an AllStarLink node you use often
- an EchoLink target you use often

### Typical Favorites workflow

- choose a Favorite
- let it load the target / mode
- press Connect

## 📝 MANUAL ENTRY

Manual entry is there when you want to type something directly instead of using a saved Favorite.

That is useful when:

- you are testing
- you are trying a one-time target
- you do not want to save it yet

## 📊 STATUS AND ACTIVITY

The status and activity areas help you see:

- what mode you are in
- whether you are connected
- which target is active
- D-Star, P25, and NXDN status when those modes are configured
- local / node activity
- changes as they happen

## 🔊 AUDIO ALERTS

Audio alerts can help you notice:

- connects
- disconnects
- activity changes

If you use them, they can make monitoring easier.

## 🔧 TROUBLESHOOTING BASICS

### If audio stops

Try:

```bash
sudo systemctl restart analog_bridge
```

### If you updated from GitHub

First decide what kind of update it was.

For a normal code-only update:

```bash
cd /var/www/html/alltune2
git pull origin main
```

For an update that includes install/setup/system-level changes:

```bash
cd /var/www/html/alltune2
git pull origin main
sudo ./setup_alltune2.sh
```

If the update changed a long-running TGIF / HBLink process, reboot once after updating so the new runtime fully takes effect.

### If D-Star, P25, or NXDN does not show up

Check these first:

- `DSTAR_ENABLED=1`, `P25_ENABLED=1`, or `NXDN_ENABLED=1` is set in `/var/www/html/alltune2/config.ini`
- `/opt/MMDVM_Bridge/dvswitch.sh` exists
- your real `MYNODE` and `DVSWITCH_NODE` values are set
- the mode already works from the terminal

Manual D-Star test:

```bash
/opt/MMDVM_Bridge/dvswitch.sh mode DSTAR
/opt/MMDVM_Bridge/dvswitch.sh tune REF030EL
```

Manual D-Star disconnect:

```bash
/opt/MMDVM_Bridge/dvswitch.sh tune 4000#
```

Manual P25 test:

```bash
/opt/MMDVM_Bridge/dvswitch.sh mode P25
/opt/MMDVM_Bridge/dvswitch.sh tune YOUR_P25_TARGET
```

Manual NXDN test:

```bash
/opt/MMDVM_Bridge/dvswitch.sh mode NXDN
/opt/MMDVM_Bridge/dvswitch.sh tune YOUR_NXDN_TARGET
```

Manual P25 / NXDN disconnect:

```bash
/opt/MMDVM_Bridge/dvswitch.sh tune 0
sleep 2
/opt/MMDVM_Bridge/dvswitch.sh mode DMR
```

If these manual commands do not work, fix the base D-Star / P25 / NXDN / DVSwitch / MMDVM_Bridge setup first.

### If something still looks wrong

Check these first:

- `/var/www/html/alltune2/config.ini`
- `/var/www/html/alltune2/tgif-hblink/hblink.cfg`
- `/var/www/html/alltune2/tgif-hblink/MMDVM_Bridge.hblink.ini`

Do not guess values.

## 🧠 SIMPLE RULES

### Edit these:

- `/var/www/html/alltune2/config.ini`
- `/var/www/html/alltune2/tgif-hblink/hblink.cfg`

Set `DSTAR_ENABLED=1`, `P25_ENABLED=1`, or `NXDN_ENABLED=1` only on systems where those modes are already working. Leave them set to `0` on systems that do not use those modes.

### Review this:

- `/var/www/html/alltune2/tgif-hblink/MMDVM_Bridge.hblink.ini`

### Leave these alone unless you already know why:

- `/opt/MMDVM_Bridge/DVSwitch.ini`
- `/opt/MMDVM_Bridge/MMDVM_Bridge.ini`
- `/opt/Analog_Bridge/Analog_Bridge.ini`

### And remember:

- do not guess values
- do not assume every update needs `setup_alltune2.sh`
- reboot once after updates that change long-running TGIF / HBLink runtime behavior

## ✅ DONE

Install → Configure → Open in browser → Connect → Enjoy

---

### Contact:

Questions? Email: [kc3kmv@yahoo.com](mailto:kc3kmv@yahoo.com)

---

## ⚠️ IMPORTANT UPDATE

Current release notes may include both code-only updates and setup-level updates.

For this release series, important recent changes include:

- Managed D-Star support when enabled in local config
- Managed P25 and NXDN support when enabled in local config
- D-Star, P25, and NXDN Live Status / keyed activity support
- D-Star, P25, and NXDN Favorites support when enabled
- TGIF / HBLink connect speed improvement
- HBLink runtime retune improvement
- HBLink log file growth disabled

For these HBLink runtime/logging updates:

```bash
cd /var/www/html/alltune2
git pull origin main
```

Then reboot once so the old running HBLink bridge process is cleared and the new runtime starts clean.

Only run:

```bash
sudo ./setup_alltune2.sh
```

when the release specifically says setup/system-level changes are included.
