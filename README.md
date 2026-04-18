# 🔧 AllTune2

A modern, simple control panel for **AllStarLink 3 + DVSwitch**.

AllTune2 gives you one place to control:

- **BrandMeister**
- **TGIF**
- **YSF**
- **AllStarLink**
- **EchoLink**

It is built to be easier to use than the older tools, while still keeping the power needed for real radio use.

---

# 🚀 Why Use AllTune2?

With AllTune2, you can:

- Connect to **BrandMeister** talkgroups
- Connect to **TGIF** talkgroups
- Use **YSF**
- Connect to **AllStarLink** nodes
- Connect to **EchoLink**
- Save and use **Favorites**
- Watch **live status**
- Use one screen instead of jumping around between tools

---

# ⚠️ Before You Install

This project assumes your system already has:

- A working **AllStarLink 3** node
- A working **DVSwitch** install
- **Analog_Bridge** installed
- **MMDVM_Bridge** installed
- A node that already works normally before AllTune2 is added

If your base node is not working yet, fix that first.

---

# 📥 First-Time Install

## 1) Go to your web directory

```bash
cd /var/www/html
```

## 2) Clone the repo

```bash
git clone https://github.com/TerryClaiborne/alltune2.git
cd alltune2
```

## 3) Run the setup script

```bash
sudo ./setup_alltune2.sh
```

That script does the heavy lifting for you.

It will:

- create needed folders and files
- prepare permissions
- create or preserve your config files
- set up the TGIF/HBLink helper environment
- install Python requirements for TGIF/HBLink
- install needed sudoers entries
- run checks on important files

---

# ✏️ Files You Must Review After Setup

This is the part that needs to be very clear.

After setup finishes, you **must review these files**.

## 1) Main AllTune2 config

```bash
nano /var/www/html/alltune2/config.ini
```

This is the main file you will edit.

Make sure these values are correct for **your** system:

- `MYNODE`
- `DVSWITCH_NODE`
- `BM_SelfcarePassword`
- `TGIF_HotspotSecurityKey`

Do not leave placeholder values in this file.

---

## 2) TGIF / HBLink config

```bash
nano /var/www/html/alltune2/tgif-hblink/hblink.cfg
```

Check:

- your node number
- your TGIF key
- any values that are specific to your system

If you do not fully understand the ports, leave them alone unless you know your system needs something different.

---

## 3) Optional advanced file

```bash
nano /var/www/html/alltune2/tgif-hblink/MMDVM_Bridge.hblink.ini
```

Most users should **leave this alone**.

Only edit this file if your system uses custom port settings or a special layout.

---

# 🔁 Updating an Existing Install

This is very important.

A normal `git pull` by itself is **not enough**.

After every update, do this:

```bash
cd /var/www/html/alltune2
git pull origin main
sudo ./setup_alltune2.sh
```

Why?

Because setup may need to:

- refresh permissions
- refresh sudoers files
- refresh helper files
- preserve and reuse your current config
- keep the install in sync with new code

So the rule is simple:

> **After every pull, run setup again.**

---

# 📡 TGIF Notes (Plain English)

TGIF does **not** behave exactly like BrandMeister.

BrandMeister usually feels faster.

TGIF uses the built-in **HBLink helper path**, and it can take longer to connect to a talkgroup.

That slower connect time is normal.

So when using TGIF:

1. choose TGIF
2. enter the talkgroup
3. press **Connect**
4. wait a little longer than you would for BM

If BM feels quick and TGIF feels slower, that is expected.

The important thing is that TGIF audio is working both ways.

---

# 🔊 Audio Notes

If audio is not working correctly, check the basics first.

A common recovery step is:

```bash
sudo systemctl restart analog_bridge
```

Also remember:

- TGIF and BM do not use the exact same path
- TGIF may take longer to fully come up
- some helper services need a little time before audio is ready

So do not judge TGIF by BM speed alone.

---

# ⭐ Main Features

- one-screen control center
- BrandMeister support
- TGIF support
- YSF support
- AllStarLink support
- EchoLink support
- Favorites
- manual target entry
- status display
- activity display
- optional audio alerts

---

# ⚠️ Important Rules

## Rule 1
If you update from GitHub, always run:

```bash
sudo ./setup_alltune2.sh
```

## Rule 2
Do not guess at config values.

If you are not sure what a value is, stop and check before changing things.

## Rule 3
Do not start editing random files just because something does not work.

Most of the time, the important files are only:

- `config.ini`
- `tgif-hblink/hblink.cfg`

And sometimes:

- `tgif-hblink/MMDVM_Bridge.hblink.ini`

---

# 🧠 Simple Way to Think About It

If you are new to AllTune2, think of it like this:

- `config.ini` = your main app settings
- `hblink.cfg` = your TGIF settings
- `setup_alltune2.sh` = the script that puts everything in the right place

That is the core idea.

---

# ✅ Basic First-Time Checklist

After install, make sure you have done this:

- ran `sudo ./setup_alltune2.sh`
- edited `config.ini`
- reviewed `tgif-hblink/hblink.cfg`
- left advanced files alone unless needed
- opened AllTune2 in your browser
- tested **BrandMeister**
- tested **TGIF**
- tested **YSF**
- tested **AllStarLink / EchoLink**

---

# ✅ Basic Update Checklist

When updating an existing system:

- run `git pull origin main`
- run `sudo ./setup_alltune2.sh`
- review your config if needed
- test BM
- test TGIF
- test other modes

---

# ❤️ Final Notes

AllTune2 is meant to make node control easier, not harder.

If you already know how painful mixed radio tools can be, the goal here is simple:

**one cleaner screen, one easier workflow, less confusion.**

If something seems complicated, the answer usually is not to edit more files.

The answer is usually to go back to the main config, check the TGIF config, and run setup again.

---

# GitHub Safety

This repo is set up so live/private files like local configs, backups, and runtime files should stay out of GitHub when used correctly.

Still, always double-check before committing.

Especially avoid uploading:

- live passwords
- live keys
- personal config files
- backup files

---

# Enjoy AllTune2

Take it one step at a time.

Install it.
Set your config.
Test BM.
Test TGIF.
Then enjoy having everything in one place.
