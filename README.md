# 🚀 AllTune2

## One Dashboard. All Your Networks.

✅ Optimized for Debian 12 & 13 on 64-bit ARM, including Raspberry Pi 4 and Raspberry Pi 5.

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
- Transceive
- Favorites
- Live status and activity
- Audio alerts

Simple. Clean. Powerful.

---

## ✨ WHAT ALLTUNE2 CAN DO

AllTune2 is meant to be a one-screen radio control center.

With it, you can:

- connect to BrandMeister talkgroups
- connect to TGIF talkgroups
- connect to YSF rooms / reflectors
- connect to D-Star, P25, and NXDN when those modes are enabled and already working on your system
- connect to AllStarLink nodes
- connect to EchoLink nodes
- use Local Monitor or Transceive
- save and load Favorites
- save a new Favorite directly from the dashboard
- use manual entry
- watch live status and activity
- use spoken audio alerts for connects and disconnects

AllTune2 does not replace ASL3, DVSwitch, Analog_Bridge, or MMDVM_Bridge. It controls them from one cleaner dashboard.

---

## 🆕 RECENT UI AND CONTROL IMPROVEMENTS

Recent versions added several important improvements:

- redesigned Control Center layout
- cleaner top navigation buttons
- dashboard **Save Favorite** button
- Save Favorite popup for manual entries
- existing Favorite detection by target + mode
- improved Saved Favorites stability
- Live Status connected-node cards
- Disconnect DVSwitch button in Live Status
- better Local Monitor / Transceive handling for managed DVSwitch modes
- spoken connect/disconnect alerts for managed modes, including D-Star
- optional web login with View Only / Signed In behavior
- disabled Control Center controls while logged out
- read-only Favorites and Live Status controls while logged out
- setup commands to set/change or disable the web login password
- Apache security hardening from the installer

The dashboard is designed so you can pick a network, enter or load a target, choose Local Monitor or Transceive, and press **Connect**.

---

## ⚠️ BEFORE YOU INSTALL

You must already have a working ASL3 / DVSwitch system.

You need:

- Working AllStarLink 3
- Working DVSwitch
- Analog_Bridge installed and running
- MMDVM_Bridge installed and running

Optional modes such as D-Star, P25, and NXDN should already be working in your base DVSwitch setup before enabling them in AllTune2.

If your base node is broken, fix that first. AllTune2 is a control panel, not a repair tool for a broken ASL3 / DVSwitch install.

---

## 📥 INSTALL FIRST TIME

Use this only for a brand-new install:

```bash
cd /var/www/html
git clone https://github.com/TerryClaiborne/alltune2.git
cd alltune2
sudo ./setup_alltune2.sh
```

The installer may take a little while during dependency checks or TGIF/HBLink setup, especially on slower hardware. Wait for the final setup summary before assuming it is stuck.

### What setup does

The setup script helps with:

- permissions
- sudoers rules
- TGIF/HBLink Python environment
- config examples
- preserving existing local config files
- helper permissions
- log rotation
- Apache security hardening

The setup script preserves your local config files when they already exist.

---

## 🔁 UPDATE / REINSTALL / REBOOT

### Normal code update

For most updates:

```bash
cd /var/www/html/alltune2
git pull origin main
```

### Update that needs setup

Run setup after pulling when the update includes installer, permissions, sudoers, Apache security, or other system-level changes:

```bash
cd /var/www/html/alltune2
git pull origin main
sudo ./setup_alltune2.sh
```

### Reboot when needed

A reboot is recommended after updates that affect long-running runtime pieces such as TGIF/HBLink.

Do **not** assume every update needs setup. Many updates only need `git pull`.

---

## ✏️ FILES YOU MUST EDIT

### 1. Main config

Edit:

```text
/var/www/html/alltune2/config.ini
```

Example:

```ini
MYNODE="YOUR NODE"
DVSWITCH_NODE="YOUR DVSWITCH NODE"
BM_SelfcarePassword="CHANGE_ME"
TGIF_HotspotSecurityKey="CHANGE_ME"
DSTAR_ENABLED=0
P25_ENABLED=0
NXDN_ENABLED=0
ALLTUNE2_AUTH_ENABLED=0
ALLTUNE2_ADMIN_USER="admin"
ALLTUNE2_ADMIN_PASSWORD_HASH=""
```

### Main config values

**MYNODE**  
Your main AllStar node number.

**DVSWITCH_NODE**  
Your private DVSwitch audio node. Many systems use `1999` or `1998`, but use whatever your system is actually configured to use.

**BM_SelfcarePassword**  
Your BrandMeister SelfCare password.

**TGIF_HotspotSecurityKey**  
Your TGIF Hotspot Security Key. This is **not** your TGIF website login password.

**DSTAR_ENABLED**  
Set to `1` only if D-Star already works on your ASL3 / DVSwitch system.

**P25_ENABLED** and **NXDN_ENABLED**  
Set these to `1` only if those modes already work on your ASL3 / DVSwitch system.

Leave optional modes disabled if you do not use them:

```ini
DSTAR_ENABLED=0
P25_ENABLED=0
NXDN_ENABLED=0
```

**ALLTUNE2_AUTH_ENABLED**  
Optional web login switch.

Use `0` for normal/no-login behavior.

Use `1` to require login before control actions are allowed.

**ALLTUNE2_ADMIN_USER**  
The single built-in admin username. Leave this as `admin`.

**ALLTUNE2_ADMIN_PASSWORD_HASH**  
The saved web-login password hash. Do not type a plain password here.

Use the setup command below to create or change this hash safely.

---

## 🔐 OPTIONAL WEB LOGIN

AllTune2 can run in normal mode or optional web-login mode.

### No Login / Normal mode

When this is set:

```ini
ALLTUNE2_AUTH_ENABLED=0
```

AllTune2 behaves like the normal dashboard. Controls are available without signing in.

### View Only mode

When this is set:

```ini
ALLTUNE2_AUTH_ENABLED=1
```

and you are not signed in, AllTune2 shows **View Only** mode.

In View Only mode:

- dashboard status still loads
- saved Favorites are still visible
- Control Center controls are disabled
- Live Status disconnect buttons are disabled
- dashboard Favorites are view-only
- Favorites page add/edit/remove actions are blocked
- connect, disconnect, DTMF, save, edit, and remove actions require login

### Login / Sign In

Click **Login** on the dashboard.

Enter the single admin password.

After login, AllTune2 shows the signed-in/admin state and the controls are available.

### Logout

Click **Logout** to return the dashboard to View Only mode.

### Set or change the web login password

Run:

```bash
sudo /var/www/html/alltune2/setup_alltune2.sh --set-admin-password
```

The setup script asks for the new password and confirmation.

It creates the password hash automatically.

The plain password is not stored.

Users do **not** need to manually generate password hashes.

### Disable web login

Run:

```bash
sudo /var/www/html/alltune2/setup_alltune2.sh --disable-auth
```

This sets:

```ini
ALLTUNE2_AUTH_ENABLED=0
```

The saved password hash is kept. If you later set `ALLTUNE2_AUTH_ENABLED=1`, the old saved password can still work.

### Normal setup does not change the web password

This normal setup command:

```bash
sudo /var/www/html/alltune2/setup_alltune2.sh
```

will not ask for a web password and will not reset the saved web-login password.

---

## 🟢 TGIF CONFIG

Edit:

```text
/var/www/html/alltune2/tgif-hblink/hblink.cfg
```

Look in the `[REPEATER-1]` section.

Example:

```ini
PASSPHRASE: your_tgif_key
CALLSIGN: YOURCALL
RADIO_ID: 330000812
OPTIONS: StartRef=19750;RelinkTime=60
```

### TGIF values

**PASSPHRASE**  
Your TGIF Hotspot Security Key.

**CALLSIGN**  
Your ham callsign.

**RADIO_ID**  
Usually your DMR / hotspot ID with a suffix. Many setups use the hotspot ID plus 1.

Example:

```text
Your hotspot ID: 330000811
Use:             330000812
```

Do not guess this value. Use what is correct for your DVSwitch / TGIF setup.

**OPTIONS**  
Optional TGIF startup options, such as a startup talkgroup.

### Review this TGIF file too

```text
/var/www/html/alltune2/tgif-hblink/MMDVM_Bridge.hblink.ini
```

Make sure the callsign and ID match what your TGIF/HBLink setup needs.

### Important TGIF note

TGIF and BrandMeister are separate networks. A talkgroup number existing on TGIF does not automatically mean you will hear users who are connected through BrandMeister.

Use BrandMeister in AllTune2 when you want the BrandMeister side. Use TGIF when you want the TGIF side.

---

## 🟠 OPTIONAL D-STAR / P25 / NXDN

D-Star, P25, and NXDN are optional.

Enable them in AllTune2 only if they already work in your base DVSwitch / MMDVM_Bridge setup.

```ini
DSTAR_ENABLED=1
P25_ENABLED=1
NXDN_ENABLED=1
```

If a mode is disabled or not configured, it will not be available in the main dropdown or Favorites. Its Live Status box may still appear, but it will stay idle.

AllTune2 does not create your D-Star registration, P25 setup, NXDN setup, reflector setup, or base MMDVM_Bridge mode configuration. It controls those modes after your base system is already working.

---

## 🚫 DO NOT EDIT THESE UNLESS YOU KNOW WHY

These files belong to the underlying DVSwitch system:

- `/opt/MMDVM_Bridge/DVSwitch.ini`
- `/opt/MMDVM_Bridge/MMDVM_Bridge.ini`
- `/opt/Analog_Bridge/Analog_Bridge.ini`

If those files are wrong, AllTune2 may not work correctly.

---

## 🌐 OPEN ALLTUNE2 IN YOUR BROWSER

Example:

```text
http://192.168.1.120/alltune2/public/
```

The full path also works:

```text
http://192.168.1.120/alltune2/public/index.php
```

Replace `192.168.1.120` with your node IP address or hostname.

### HTTPS and outside access

For local LAN use, normal HTTP may be enough.

For outside access, the safest recommendation is still **Tailscale** or another VPN/private tunnel.

If you want public browser access, use:

- a real hostname or DDNS name
- router forwarding for TCP 80 and 443
- Apache HTTPS
- a trusted certificate such as Let's Encrypt
- AllTune2 web login enabled

Example:

```text
https://your-ddns-name/alltune2/public/
```

DDNS gives you a hostname. It does **not** automatically give you trusted HTTPS.

A self-signed or snakeoil certificate will still show browser warnings. That is fixed by installing a trusted certificate for the hostname you actually use.

Raw public-IP HTTPS is not recommended for normal users because browsers will usually show certificate warnings unless the certificate is valid for that exact IP address.

---

## 🖥️ HOW TO USE ALLTUNE2

Basic use:

- choose the network or mode
- choose Local Monitor or Transceive if needed
- enter a target or choose a Favorite
- press **Connect**
- watch Live Status and Activity
- press **Disconnect**, **Disconnect DVSwitch**, or **Disconnect All** when needed

### Control Center

The Control Center is where you select the network, target, and Link Mode.

The Link Mode dropdown controls how the private DVSwitch audio node is linked:

- **Local Monitor** for monitoring/listening use
- **Transceive** for normal radio-side transmit/receive use

AllTune2 now re-applies the selected Link Mode when changing between supported managed modes, so you should not normally have to press Disconnect DVSwitch just to change Local Monitor / Transceive.

If optional web login is enabled and you are logged out, the Control Center is disabled until you sign in.

---

## 🔵 BRANDMEISTER

Use BrandMeister for BM talkgroups.

Typical workflow:

- choose BrandMeister
- enter a talkgroup or choose a BM Favorite
- press Connect
- wait for status to show the connection

To change BM talkgroups:

- enter a new talkgroup **or choose another BM Favorite**
- press Connect again

BrandMeister is usually one of the faster paths.

---

## 🟢 TGIF

Use TGIF for TGIF talkgroups.

Typical workflow:

- choose TGIF
- enter a talkgroup or choose a TGIF Favorite
- press Connect
- wait for the TGIF path to come up

To change TGIF talkgroups:

- enter a new talkgroup **or choose another TGIF Favorite**
- press Connect again

TGIF can take longer than BrandMeister to connect or disconnect. That is normal because TGIF/HBLink has more runtime pieces involved.

---

## 🟡 YSF

Use YSF for YSF rooms / reflectors.

Typical workflow:

- choose YSF
- enter the YSF target or choose a YSF Favorite
- press Connect
- watch Live Status

---

## 🟠 D-STAR

Use D-Star for D-Star reflectors when D-Star is enabled and working on your system.

Typical workflow:

- make sure `DSTAR_ENABLED=1` is set in `config.ini`
- choose D-Star
- enter the D-Star target or choose a D-Star Favorite
- press Connect
- watch Live Status

---

## 🟤 P25

Use P25 when P25 is enabled and working on your system.

Typical workflow:

- make sure `P25_ENABLED=1` is set in `config.ini`
- choose P25
- enter the P25 target or choose a P25 Favorite
- press Connect
- watch Live Status

---

## ⚫ NXDN

Use NXDN when NXDN is enabled and working on your system.

Typical workflow:

- make sure `NXDN_ENABLED=1` is set in `config.ini`
- choose NXDN
- enter the NXDN target or choose an NXDN Favorite
- press Connect
- watch Live Status

---

## 🔴 ALLSTARLINK

Use AllStarLink for direct AllStar node connections.

Typical workflow:

- choose AllStarLink
- enter the node number or choose an AllStarLink Favorite
- press Connect
- watch Live Status
- disconnect when done

---

## 🟣 ECHOLINK

Use EchoLink for EchoLink node connections.

Typical workflow:

- choose EchoLink
- enter the EchoLink node number or choose an EchoLink Favorite
- press Connect
- watch Live Status
- disconnect when done

---

## ⭐ FAVORITES

Favorites save time.

Favorites can be used for:

- BM talkgroups
- TGIF talkgroups
- YSF targets
- D-Star targets
- P25 targets
- NXDN targets
- AllStarLink nodes
- EchoLink nodes

### Loading a Favorite

- click or choose the Favorite
- AllTune2 fills in the target and mode
- press Connect

### Saving a Favorite from the dashboard

The dashboard includes a **Save Favorite** button.

Use it when you manually type a target and want to save it.

If the same target and mode already exist, AllTune2 shows that it found an existing Favorite and lets you update it instead of creating a duplicate.

If optional web login is enabled and you are logged out, Favorites are visible but view-only. Clicking a Favorite will not load it into the Control Center until you sign in.

---

## 📝 MANUAL ENTRY

Manual entry is useful when:

- you are testing a target
- you are trying something once
- you do not want to save it yet

Enter the target, choose the mode, then press Connect.

---

## 📊 LIVE STATUS AND ACTIVITY

Live Status helps show:

- current network / mode
- active target
- private DVSwitch link state
- AllStarLink / EchoLink connected nodes
- keyed or active rows when activity is detected
- D-Star, P25, and NXDN status when configured

The **Disconnect DVSwitch** button removes the private DVSwitch link without doing a full Asterisk restart.

The **Disconnect All** button performs a full reset and restarts Asterisk.

If optional web login is enabled and you are logged out, Live Status disconnect buttons are disabled.

---

## 🔊 AUDIO ALERTS

Audio alerts can announce connects and disconnects.

They can be helpful when monitoring node activity without staring at the screen.

Recent updates improved connect/disconnect alerts for managed digital modes, including D-Star.

---

## 🔐 SECURITY HARDENING

The setup script installs Apache protection for sensitive AllTune2 files and folders.

This helps block direct browser access to local config, git, helper, runtime, log, and data files while still allowing the public dashboard and API to work.

This is handled by the installer when Apache is available.

The Apache hardening also blocks direct browser access to private helper areas such as `app`, `data`, `logs`, `run`, `tools`, `stfu`, and `tgif-hblink` while still allowing the dashboard and API to work.

Optional web login protects write/control actions, but you should still use Tailscale/VPN or trusted HTTPS for outside access.

---

## 🔧 TROUBLESHOOTING BASICS

### If audio stops

Try restarting Analog_Bridge:

```bash
sudo systemctl restart analog_bridge
```

### If TGIF does not connect

Check:

- `/var/www/html/alltune2/config.ini`
- `/var/www/html/alltune2/tgif-hblink/hblink.cfg`
- `/var/www/html/alltune2/tgif-hblink/MMDVM_Bridge.hblink.ini`

TGIF may take longer than other modes to start or stop. Wait for status to finish before clicking repeatedly.

### If D-Star, P25, or NXDN does not show up

Check:

- the mode is enabled in `config.ini`
- your real `MYNODE` and `DVSWITCH_NODE` are set
- `/opt/MMDVM_Bridge/dvswitch.sh` exists
- the mode already works in the underlying DVSwitch setup

### If web login does not work

Check the auth settings:

```bash
grep -nE 'ALLTUNE2_AUTH_ENABLED|ALLTUNE2_ADMIN_USER|ALLTUNE2_ADMIN_PASSWORD_HASH' /var/www/html/alltune2/config.ini
```

To set or change the password:

```bash
sudo /var/www/html/alltune2/setup_alltune2.sh --set-admin-password
```

To disable login:

```bash
sudo /var/www/html/alltune2/setup_alltune2.sh --disable-auth
```

### If HTTPS shows a certificate warning

Make sure you are using the same hostname that the certificate was issued for.

A certificate for `node.local` or a snakeoil certificate will not be trusted for a public DDNS name.

For public browser access, use a DDNS/domain hostname with a trusted certificate, or use Tailscale/VPN.

### If an update behaves strangely

For code-only updates, `git pull` is usually enough.

If setup, permissions, sudoers, Apache security, or runtime helpers changed, run:

```bash
cd /var/www/html/alltune2
sudo ./setup_alltune2.sh
```

If TGIF/HBLink runtime code changed, rebooting once after the update is recommended.

---

## 🧠 SIMPLE RULES

Edit these:

- `/var/www/html/alltune2/config.ini`
- `/var/www/html/alltune2/tgif-hblink/hblink.cfg`

Review this if TGIF needs troubleshooting:

- `/var/www/html/alltune2/tgif-hblink/MMDVM_Bridge.hblink.ini`

Leave these alone unless you know why:

- `/opt/MMDVM_Bridge/DVSwitch.ini`
- `/opt/MMDVM_Bridge/MMDVM_Bridge.ini`
- `/opt/Analog_Bridge/Analog_Bridge.ini`

Remember:

- do not guess values
- do not paste passwords publicly
- do not commit `config.ini`
- do not commit `data/favorites.txt`
- do not expose AllTune2 publicly without understanding the risk
- use Tailscale/VPN or trusted HTTPS for outside access
- do not assume every update needs setup
- enable D-Star, P25, or NXDN only when those modes already work on your base system

---

## ✅ DONE

Install → Configure → Open in browser → Connect → Enjoy

---

### Contact

Questions? Email: [kc3kmv@yahoo.com](mailto:kc3kmv@yahoo.com)

---

## ⚠️ IMPORTANT UPDATE NOTES

Recent release series highlights:

- redesigned Control Center
- dashboard Save Favorite workflow
- top navigation polish
- Apache security hardening
- STFU/BM log rotation support
- D-Star, P25, and NXDN support when enabled
- Live Status improvements
- managed Local Monitor / Transceive link-mode fixes
- D-Star/P25/NXDN audio-alert improvements
- TGIF/HBLink stability and retune improvements
- optional web login and View Only dashboard behavior
- setup-managed web login password hash
- disabled Control Center, Live Status disconnect, and Favorites loading while logged out
- HTTPS/DDNS/Tailscale documentation

For most updates:

```bash
cd /var/www/html/alltune2
git pull origin main
```

Run setup only when the release includes install/setup/system-level changes:

```bash
sudo ./setup_alltune2.sh
```

For the 1.21.0 optional web login release, run setup after pulling:

```bash
sudo /var/www/html/alltune2/setup_alltune2.sh
```

To set or change the web login password:

```bash
sudo /var/www/html/alltune2/setup_alltune2.sh --set-admin-password
```

To disable web login:

```bash
sudo /var/www/html/alltune2/setup_alltune2.sh --disable-auth
```
