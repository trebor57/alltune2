# 🚀 AllTune2

## One Dashboard. All Your Networks.

AllTune2 is a modern control panel for **AllStarLink 3 + DVSwitch**.

It gives you one place to work with:

- **BrandMeister**
- **TGIF**
- **YSF**
- **AllStarLink**
- **EchoLink**
- **Local Monitor**
- **Transceiver**
- **Favorites**
- **Live status and activity**

Simple. Clean. Powerful.

---

# ✨ WHAT ALLTUNE2 CAN DO

AllTune2 is meant to be a **one-screen radio control center**.

With it, you can:

- connect to **BrandMeister** talkgroups
- connect to **TGIF** talkgroups
- connect to **YSF** reflectors / rooms
- connect to **AllStarLink** nodes
- connect to **EchoLink** nodes
- use **Local Monitor**
- use **Transceiver**
- save and use **Favorites**
- use **manual entry**
- watch **live status and activity**
- use **audio alerts** if enabled

Some local functions can also be used alongside BM, TGIF, or YSF operation depending on your setup and workflow.

---

# ⚠️ BEFORE YOU INSTALL

You MUST already have:

- Working **AllStarLink 3 (ASL3)**
- Working **DVSwitch**
- **Analog_Bridge** running
- **MMDVM_Bridge** running

If your node is not already working, fix that first.

AllTune2 sits on top of a working base system.  
It is **not** meant to repair a broken base install.

---

# 📥 INSTALL (FIRST TIME)

Use these commands only for a brand-new install:

```bash
cd /var/www/html
git clone https://github.com/TerryClaiborne/alltune2.git
cd alltune2
sudo ./setup_alltune2.sh
```

### What the setup script does

The setup script helps by:

- setting permissions
- building the TGIF / HBLink backend
- installing requirements
- creating config files if missing
- preserving existing config files
- refreshing helper files

---

# 🔁 UPDATE OR REINSTALL

Use these commands if AllTune2 is already installed and you want to:

- update from GitHub
- refresh a broken install
- reinstall without deleting your current config

```bash
cd /var/www/html/alltune2
git pull origin main
sudo ./setup_alltune2.sh
```

## Important

Always run `setup_alltune2.sh` after `git pull`.

Do **not** stop at `git pull` by itself.

The setup script helps:

- refresh permissions
- refresh helper files
- keep install files in sync
- preserve your existing config files

---

# 🌐 OPEN ALLTUNE2 IN YOUR BROWSER

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

Example:

```text
http://node67040.local/alltune2/public/
```

The shorter `/public/` address is usually easier and works fine.

---

# ✏️ FILES YOU MUST EDIT

## 1. Main Config
`/var/www/html/alltune2/config.ini`

Example:

```ini
MYNODE=12345
DVSWITCH_NODE=1999
BM_SelfcarePassword=your_password
TGIF_HotspotSecurityKey=your_key
```

### What these mean

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

---

## 2. TGIF Config
`/var/www/html/alltune2/tgif-hblink/hblink.cfg`

Look in the `[REPEATER-1]` section.

Example:

```ini
PASSPHRASE: your_tgif_key
CALLSIGN: YOURCALL
RADIO_ID: 330000812
OPTIONS: StartRef=19750;RelinkTime=60
```

### What these mean

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
Your **DMR / BrandMeister Hotspot ID + 1**

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

---

## 3. Review This File
`/var/www/html/alltune2/tgif-hblink/MMDVM_Bridge.hblink.ini`

Example:

```ini
Callsign=YOURCALL
Id=330000812
```

### What these mean

**Callsign**  
Your ham callsign.

Example:

```text
Callsign=KC3KMV
```

**Id**  
Your **DMR / BrandMeister Hotspot ID + 1**

Real example:

```text
Your hotspot ID: 330000811
Use:             330000812
```

Do **NOT** use your original hotspot ID unchanged.

### Optional values

Most users can leave these as `0`:

```ini
RXFrequency=0
TXFrequency=0
```

These only matter if you run a repeater.

If you do **not** run a repeater, leaving them at `0` is fine and has no effect on normal operation.

---

# 🚫 DO NOT EDIT THESE UNLESS YOU ALREADY KNOW WHY

These files must already be working correctly on your system:

- `/opt/MMDVM_Bridge/DVSwitch.ini`
- `/opt/MMDVM_Bridge/MMDVM_Bridge.ini`
- `/opt/Analog_Bridge/Analog_Bridge.ini`

If those files are broken, AllTune2 will not work correctly.

---

# 🖥️ HOW TO USE ALLTUNE2

Once AllTune2 is installed and configured, open it in your browser and use the control center.

Basic idea:

1. choose the network or mode
2. enter a target or choose a Favorite
3. press **Connect**
4. watch the status / activity area
5. press **Disconnect** when done

---

# 🔵 BRANDMEISTER

Use BrandMeister when you want to connect to a BM talkgroup.

### Typical BM workflow

1. choose **BrandMeister**
2. enter the talkgroup number
3. press **Connect**
4. wait for the status to show the connection
5. use **Disconnect** when you want to leave

### BM talkgroup changes

BrandMeister is usually one of the faster paths.

If you want to change from one BM talkgroup to another:

1. enter the new talkgroup
2. press **Connect** again

---

# 🟢 TGIF

Use TGIF when you want to connect to a TGIF talkgroup.

### Typical TGIF workflow

1. choose **TGIF**
2. enter the talkgroup number
3. press **Connect**
4. wait for the TGIF path to come up
5. watch status / activity for confirmation
6. use **Disconnect** when finished

### Important TGIF note

TGIF may take a little longer to connect than BrandMeister.

That is normal.

---

# 🟡 YSF

Use YSF when you want to connect to a YSF room or reflector.

### Typical YSF workflow

1. choose **YSF**
2. enter the YSF target you want
3. press **Connect**
4. watch the status area
5. use **Disconnect** when done

---

# 🔴 ALLSTARLINK

Use AllStarLink when you want to work with AllStar nodes directly.

### Typical AllStarLink workflow

1. choose **AllStarLink**
2. enter the node number you want
3. press **Connect**
4. watch the live status / activity
5. disconnect when finished

AllStarLink mode is useful for:

- direct node linking
- node monitoring
- local AllStar activity

---

# 🟣 ECHOLINK

Use EchoLink when you want to connect to an EchoLink node.

### Typical EchoLink workflow

1. choose **EchoLink**
2. enter the EchoLink node number
3. press **Connect**
4. watch status for confirmation
5. disconnect when done

---

# 🎧 LOCAL MONITOR

Local Monitor is there for local monitoring use.

That means it can be used when you want to:

- listen locally
- monitor what is happening on the node
- work in a more local / direct way

---

# 🎙️ TRANSCEIVER

Transceiver mode is there for direct radio-side operation.

In simple terms:

- **Local Monitor** is for local listening / monitoring
- **Transceiver** is for direct local radio operation

These are local functions, not just network destination fields.

---

# ⭐ FAVORITES

Favorites help save time.

Use Favorites when you have:

- a BM talkgroup you use often
- a TGIF talkgroup you use often
- a YSF room you use often
- an AllStarLink node you use often
- an EchoLink target you use often

### Typical Favorites workflow

1. choose a Favorite
2. let it load the target / mode
3. press **Connect**

---

# 📝 MANUAL ENTRY

Manual entry is there when you want to type something directly instead of using a saved Favorite.

That is useful when:

- you are testing
- you are trying a one-time target
- you do not want to save it yet

---

# 📊 STATUS AND ACTIVITY

The status and activity areas help you see:

- what mode you are in
- whether you are connected
- which target is active
- local / node activity
- changes as they happen

---

# 🔊 AUDIO ALERTS

Audio alerts can help you notice:

- connects
- disconnects
- activity changes

If you use them, they can make monitoring easier.

---

# 🔧 TROUBLESHOOTING BASICS

## If audio stops

Try:

```bash
sudo systemctl restart analog_bridge
```

## If you updated from GitHub

Always run:

```bash
cd /var/www/html/alltune2
git pull origin main
sudo ./setup_alltune2.sh
```

## If something still looks wrong

Check these first:

- `/var/www/html/alltune2/config.ini`
- `/var/www/html/alltune2/tgif-hblink/hblink.cfg`
- `/var/www/html/alltune2/tgif-hblink/MMDVM_Bridge.hblink.ini`

Do **not** guess values.

---

# 🧠 SIMPLE RULES

### Edit these:
- `/var/www/html/alltune2/config.ini`
- `/var/www/html/alltune2/tgif-hblink/hblink.cfg`

### Review this:
- `/var/www/html/alltune2/tgif-hblink/MMDVM_Bridge.hblink.ini`

### Leave these alone unless you already know why:
- `/opt/MMDVM_Bridge/DVSwitch.ini`
- `/opt/MMDVM_Bridge/MMDVM_Bridge.ini`
- `/opt/Analog_Bridge/Analog_Bridge.ini`

### And remember:
- do not guess values
- do not stop at `git pull`
- always run `sudo ./setup_alltune2.sh` after updating

---

# ✅ DONE

Install → Configure → Open in browser → Connect → Enjoy
