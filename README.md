# 🚀 AllTune2

## One Dashboard. All Your Networks.

AllTune2 is a modern web dashboard for controlling and monitoring an ASL3 / DVSwitch node.

It brings common radio network controls into one clean interface:

- BrandMeister
- TGIF
- YSF
- D-Star
- P25
- NXDN
- AllStarLink
- EchoLink

AllTune2 is designed to keep the radio side reliable while giving the operator a simple browser-based control panel for changing talkgroups, connecting nodes, managing favorites, viewing live activity, and safely controlling DVSwitch/ASL-related actions.

---

## ✨ What AllTune2 Can Do

AllTune2 provides:

- One dashboard for multiple digital and analog network paths
- BrandMeister control through the AllTune2 local BM/STFU-style helper
- TGIF control through the AllTune2 local HBLink helper
- YSF, D-Star, P25, and NXDN DVSwitch control
- Direct AllStarLink and EchoLink connection handling
- Saved favorites
- Manual TG / node / target entry
- Local Monitor and Transceive link mode support
- Live Status display
- Gateway and local activity display
- DTMF send controls
- Optional web login with read-only logged-out dashboard behavior
- Apache hardening for config/runtime/private files
- Installer support for setup, update, web login password changes, and disabling auth

---

## 🆕 Version 1.21.0 — Optional Web Login and Read-Only Dashboard Security

Version 1.21.0 adds optional web login and read-only dashboard protection.

When web login is enabled:

- Logged-out users can view the dashboard, live status, and saved favorites.
- Logged-out users cannot connect, disconnect, send DTMF, save favorites, edit favorites, remove favorites, or change Control Center settings.
- The Control Center is disabled while logged out.
- Live Status disconnect buttons are disabled while logged out.
- Dashboard favorites are visible but view-only while logged out.
- The Favorites management page can be viewed while logged out, but add/edit/remove actions require login.
- API write actions are protected.
- CSRF protection is used for authenticated write actions.
- Session cookies use hardened settings.
- HTTPS-aware session handling is included.

When web login is disabled, AllTune2 works like the normal dashboard.

---

## ⚠️ Before You Install

AllTune2 is intended for systems already running ASL3 / DVSwitch.

You should already have your node and DVSwitch stack basically working before installing AllTune2.

You need:

- ASL3 / Asterisk
- DVSwitch
- Apache with PHP
- sudo access
- access to `/var/www/html`
- a working node number
- a private DVSwitch node number
- valid BrandMeister and/or TGIF values if you use those modes

AllTune2 does not replace ASL3, DVSwitch, MMDVM_Bridge, Analog_Bridge, P25Gateway, NXDNGateway, or D-Star Gateway. It controls and monitors the installed system.

---

## 📥 Install First Time

Clone the repository:

```bash
cd /var/www/html
sudo git clone https://github.com/TerryClaiborne/alltune2.git
```

Run setup:

```bash
sudo /var/www/html/alltune2/setup_alltune2.sh
```

Then edit the required config files before using the dashboard.

---

### What Setup Does

The setup script:

- creates needed directories
- creates `config.ini` if missing
- creates `config.ini.example` if missing
- creates `data/favorites.txt` if missing
- preserves existing `config.ini`
- preserves existing `favorites.txt`
- preserves existing TGIF/HBLink config files
- applies correct permissions
- installs/validates sudoers rules
- installs Apache hardening rules
- checks PHP, shell, and Python syntax
- checks required files
- checks TGIF/HBLink helper files
- builds/checks the TGIF/HBLink Python venv when needed
- does not overwrite external DVSwitch config files

Normal setup/update does **not** ask for a web login password and does **not** change existing web login settings.

---

## 🔁 Update / Reinstall / Reboot

### Normal Code Update

Use this when updating an existing Git checkout:

```bash
cd /var/www/html/alltune2
sudo git pull origin main
sudo /var/www/html/alltune2/setup_alltune2.sh
```

Normal setup/update preserves:

- `config.ini`
- `data/favorites.txt`
- `tgif-hblink/hblink.cfg`
- TGIF/HBLink runtime identity files
- existing web login settings
- existing web login password hash

---

### Reboot When Needed

If services act stale after a major update:

```bash
sudo reboot
```

After reboot, open the dashboard again and test the modes you use.

---

## ✏️ Files You Must Edit

### Main Config

Edit:

```bash
sudo nano /var/www/html/alltune2/config.ini
```

Main values:

```ini
MYNODE="YOUR NODE"
DVSWITCH_NODE="YOUR DVSWITCH NODE"
BM_SelfcarePassword="CHANGE_ME"
TGIF_HotspotSecurityKey="CHANGE_ME"
```

Optional web login values:

```ini
ALLTUNE2_AUTH_ENABLED=0
ALLTUNE2_ADMIN_USER="admin"
ALLTUNE2_ADMIN_PASSWORD_HASH=""
```

Do not commit your real `config.ini` to GitHub.

---

### Main Config Values

**MYNODE**

Your main ASL node number.

Example:

```ini
MYNODE="67040"
```

**DVSWITCH_NODE**

Your private local DVSwitch node used for the AllTune2 audio/control path.

Example:

```ini
DVSWITCH_NODE="1957"
```

**BM_SelfcarePassword**

Your BrandMeister SelfCare password.

**TGIF_HotspotSecurityKey**

Your TGIF hotspot security key.

This is **not** your TGIF website login password.

---

## 🔐 Optional Web Login

AllTune2 can run in two ways:

1. **No Login / Normal mode**
2. **Web Login enabled**

Web login is optional.

By default, new installs should start with login disabled:

```ini
ALLTUNE2_AUTH_ENABLED=0
```

When login is disabled, AllTune2 works like the normal dashboard.

When login is enabled, the dashboard becomes read-only until you sign in.

---

## 🔑 Web Login Setup Commands

### Set or Change the Web Login Password

Run:

```bash
sudo /var/www/html/alltune2/setup_alltune2.sh --set-admin-password
```

This asks for:

```text
New admin password:
Confirm admin password:
```

The setup script creates the password hash automatically.

You do **not** manually create the hash.

The plain password is **not** stored.

The saved hash is written to:

```ini
ALLTUNE2_ADMIN_PASSWORD_HASH="..."
```

Web login is enabled automatically:

```ini
ALLTUNE2_AUTH_ENABLED=1
```

If you press Enter with no password, no changes are made. To turn login off, use `--disable-auth` instead.

---

### Disable Web Login

Run:

```bash
sudo /var/www/html/alltune2/setup_alltune2.sh --disable-auth
```

This sets:

```ini
ALLTUNE2_AUTH_ENABLED=0
```

The existing saved password hash is kept.

That means you can later set:

```ini
ALLTUNE2_AUTH_ENABLED=1
```

and the old saved password will work again.

You can also run `--set-admin-password` later to set a new password.

---

### Normal Setup/Update Does Not Change the Password

This command:

```bash
sudo /var/www/html/alltune2/setup_alltune2.sh
```

does **not** ask for a web login password.

It does **not** reset the password.

It does **not** enable or disable login.

It preserves the current web login settings.

---

## 👤 Web Login User States

### No Login / Normal

Shown when:

```ini
ALLTUNE2_AUTH_ENABLED=0
```

Behavior:

- dashboard works normally
- controls are available
- no login is required
- same behavior as traditional AllTune2 operation

---

### View Only

Shown when web login is enabled and you are not signed in.

Behavior:

- dashboard loads
- live status loads
- saved favorites are visible
- Favorites page can be viewed
- Control Center is disabled
- favorites are view-only
- Live Status disconnect buttons are disabled
- connect/disconnect actions are blocked
- DTMF send is blocked
- save/edit/delete favorites are blocked

This lets someone view status without being able to control the node.

---

### Login / Sign In

Click **Login** from the dashboard.

The password box should be active automatically.

Enter the single admin password.

AllTune2 uses one administrator login.

It is not a multi-user account system.

---

### Signed In / Admin

Shown after successful login.

Behavior:

- Control Center works
- connect/disconnect works
- Live Status disconnect buttons work
- DTMF send works
- save favorites works
- Favorites page add/edit/remove works

---

### Logout

Click **Logout** to end the control session.

After logout, AllTune2 returns to View Only mode if web login is enabled.

---

## 🔒 Password Hash Explanation

AllTune2 does not store the plain password.

When you run:

```bash
sudo /var/www/html/alltune2/setup_alltune2.sh --set-admin-password
```

the setup script creates a secure password hash and stores that hash in `config.ini`.

Users do not need to run PHP commands to generate hashes manually.

Do not put a plain password in `config.ini`.

Do not share your password hash publicly.

Do not commit `config.ini` to GitHub.

---

## 🌐 HTTPS, DDNS, Tailscale, VPN, and Public Access

### Recommended Safest Outside Access

The safest way to access AllTune2 from outside your home network is:

- Tailscale
- VPN
- another private tunnel you control

This keeps the dashboard off the open public internet.

---

### Public Browser Access

If you want public browser access, use:

- a real domain or DDNS hostname
- router port forwarding for TCP 80 and TCP 443
- Apache HTTPS
- a trusted certificate such as Let’s Encrypt
- AllTune2 web login enabled

Example public URL:

```text
https://yourname.example.org/alltune2/public/
```

Do not expose AllTune2 publicly without understanding the risk.

If you expose AllTune2 publicly, keep web login enabled.

---

### DDNS and Let’s Encrypt

DDNS gives your changing public IP address a hostname.

Example:

```text
yourname.ddns.example
```

DDNS alone does **not** give trusted HTTPS.

For trusted HTTPS, Apache must serve a certificate for the hostname you actually browse to.

A normal path is:

```bash
sudo apt-get install certbot python3-certbot-apache
sudo certbot --apache -d yourname.example.org
```

Then test renewal:

```bash
sudo certbot renew --dry-run
```

Certbot normally installs a systemd timer to renew certificates automatically.

Your router must keep ports 80 and 443 forwarded to the node for normal HTTP-01 renewal unless you use another certificate validation method.

---

### Self-Signed / Snakeoil Certificate Warning

Many ASL3/DVSwitch systems start with a self-signed Apache certificate.

Browsers will warn about certificates such as:

```text
node.local
node67040.local
ssl-cert-snakeoil
```

That warning is not fixed by AllTune2 code.

It is fixed by using a trusted certificate for the hostname you actually browse to.

---

### Public IP Warning

Browsing directly to a raw public IP address, such as:

```text
https://73.x.x.x/alltune2/public/
```

will usually show certificate warnings unless you have a trusted certificate for that exact IP address.

For most users, use a DDNS/domain hostname or Tailscale/VPN instead.

---

### Reverse Proxy Note

If HTTPS is terminated by a reverse proxy, the proxy should send:

```text
X-Forwarded-Proto: https
```

AllTune2 checks HTTPS/proxy headers so the session cookie can be marked secure when HTTPS is being used correctly.

---

## 🟢 TGIF Config

TGIF uses the AllTune2-local HBLink helper.

Main TGIF directory:

```bash
/var/www/html/alltune2/tgif-hblink
```

Main TGIF config:

```bash
/var/www/html/alltune2/tgif-hblink/hblink.cfg
```

Example file:

```bash
/var/www/html/alltune2/tgif-hblink/hblink.cfg.example
```

If missing, setup creates needed example/runtime files where appropriate.

---

### TGIF Values

Review and set your TGIF/HBLink identity values carefully.

TGIF/HBLink often needs both:

- base DMR ID
- hotspot/repeater-style suffixed radio ID

If TGIF does not connect, review:

```bash
/var/www/html/alltune2/tgif-hblink/hblink.cfg
/var/www/html/alltune2/tgif-hblink/MMDVM_Bridge.hblink.ini
/opt/MMDVM_Bridge/DVSwitch.ini
/opt/MMDVM_Bridge/MMDVM_Bridge.ini
/opt/Analog_Bridge/Analog_Bridge.ini
```

---

## 🟠 Optional D-Star / P25 / NXDN

D-Star, P25, and NXDN are optional.

They must be enabled in `config.ini` if you use them.

Example:

```ini
DSTAR_ENABLED=1
P25_ENABLED=1
NXDN_ENABLED=1
```

If they are not enabled/configured, AllTune2 will show them as unavailable or keep their controls disabled.

---

## 🚫 Do Not Edit These Unless You Know Why

Do not casually edit:

```bash
/opt/MMDVM_Bridge/MMDVM_Bridge.ini
/opt/MMDVM_Bridge/DVSwitch.ini
/opt/Analog_Bridge/Analog_Bridge.ini
```

AllTune2 setup does not overwrite these files.

Only change them when you understand the DVSwitch side.

---

## 🌐 Open AllTune2 in Your Browser

Local/LAN example:

```text
http://node-ip/alltune2/public/
```

HTTPS/DDNS example:

```text
https://your-ddns-name/alltune2/public/
```

If web login is enabled and you are logged out, you will see View Only mode.

Click **Login** to sign in.

---

## 🖥️ How to Use AllTune2

### Control Center

Use the Control Center to:

- enter a TG / node / target
- choose a mode
- choose Link Mode
- connect
- disconnect
- disconnect DVSwitch
- disconnect all
- send DTMF
- save a manual entry as a favorite

If web login is enabled and you are logged out, the Control Center is disabled.

---

## 🔵 BrandMeister

BrandMeister uses the AllTune2-local BM receive/STFU-style helper.

To connect:

1. Choose BrandMeister.
2. Enter the talkgroup.
3. Press Connect.

BrandMeister supports fast talkgroup switching by entering another TG and pressing Connect again.

Private calls are supported with a trailing `#` where applicable.

---

## 🟢 TGIF

TGIF uses the AllTune2-local HBLink helper.

To connect:

1. Choose TGIF.
2. Enter the talkgroup.
3. Press Connect.

TGIF startup can take longer than BrandMeister, especially on slower hardware.

If TGIF fails, review the HBLink config values and identity values.

---

## 🟡 YSF

To use YSF:

1. Choose YSF.
2. Enter the YSF reflector/target number.
3. Press Connect.

YSF uses the configured DVSwitch path.

---

## 🟠 D-Star

To use D-Star:

1. Enable D-Star in `config.ini`.
2. Choose D-Star.
3. Enter the target.
4. Press Connect.

If D-Star is not enabled or configured, AllTune2 will disable the connect path for that mode.

---

## 🟤 P25

To use P25:

1. Enable P25 in `config.ini`.
2. Choose P25.
3. Enter the target.
4. Press Connect.

If P25 is not enabled or configured, AllTune2 will disable the connect path for that mode.

---

## ⚫ NXDN

To use NXDN:

1. Enable NXDN in `config.ini`.
2. Choose NXDN.
3. Enter the target.
4. Press Connect.

If NXDN is not enabled or configured, AllTune2 will disable the connect path for that mode.

---

## 🔴 AllStarLink

AllStarLink direct connections use the direct fast lane.

To connect:

1. Choose AllStarLink.
2. Enter the node number.
3. Press Connect.

AllStarLink favorites are labeled as ASL.

---

## 🟣 EchoLink

EchoLink direct connections use the direct fast lane.

To connect:

1. Choose EchoLink.
2. Enter the EchoLink target.
3. Press Connect.

EchoLink favorites are labeled as E/L.

EchoLink requires a working EchoLink setup on the ASL3 system.

---

## ⭐ Favorites

AllTune2 supports saved favorites for common talkgroups, nodes, and targets.

Favorites are stored in:

```bash
/var/www/html/alltune2/data/favorites.txt
```

Do not commit your personal `favorites.txt` to GitHub.

---

### Loading a Favorite

When signed in:

1. Click a favorite.
2. The target and mode load into the Control Center.
3. Press Connect.

When logged out in View Only mode:

- favorites are visible
- favorites do not load into the Control Center
- controls remain disabled

---

### Saving a Favorite from the Dashboard

When signed in:

1. Enter a TG / node / target in the Control Center.
2. Choose the network mode.
3. Click Save Favorite.
4. Enter a name/description.
5. Save.

When logged out, Save Favorite is disabled.

---

### Favorites Page

The Favorites page allows viewing and managing saved favorites.

When logged out:

- favorites can be viewed
- add/edit/remove actions are disabled

When signed in:

- add/edit/remove actions are available

---

## 📝 Manual Entry

Manual entry is used when you do not want to save a favorite.

Enter the TG / node / target directly into the Control Center, choose the mode, and press Connect.

When web login is enabled and you are logged out, manual entry is disabled.

---

## 📊 Live Status and Activity

Live Status shows current connection and activity state.

It can show:

- DVSwitch private link state
- direct AllStarLink connections
- direct EchoLink connections
- managed digital network state
- local/gateway activity
- connected node cards
- disconnect buttons for active rows

When logged out in View Only mode, Live Status disconnect buttons are disabled.

---

## 🔊 Audio Alerts

Audio alerts can announce connect/disconnect events in the browser.

If Audio Alerts are disabled, AllTune2 will not speak browser alerts.

Audio Alerts are part of the Control Center preferences and are disabled while logged out if web login is enabled.

---

## 🔐 Security Hardening

AllTune2 setup installs Apache hardening rules to block direct browser access to private files and directories.

This includes protection for:

- `.git`
- `app`
- `data`
- `docs`
- `logs`
- `run`
- `tools`
- `stfu`
- `tgif-hblink`
- config files
- backup files
- runtime files
- scripts
- logs
- database/cache-style files

PHP can still read needed files locally from the filesystem.

Browsers should not be able to directly download private config/runtime files.

---

## 🔧 Troubleshooting Basics

### If Audio Stops

Try:

```bash
sudo systemctl restart analog_bridge
```

If needed:

```bash
sudo reboot
```

---

### If TGIF Does Not Connect

Check:

```bash
/var/www/html/alltune2/config.ini
/var/www/html/alltune2/tgif-hblink/hblink.cfg
/var/www/html/alltune2/tgif-hblink/MMDVM_Bridge.hblink.ini
/opt/MMDVM_Bridge/DVSwitch.ini
/opt/MMDVM_Bridge/MMDVM_Bridge.ini
/opt/Analog_Bridge/Analog_Bridge.ini
```

Also confirm TGIF/HBLink identity values are correct.

---

### If D-Star, P25, or NXDN Does Not Show Up

Check that the mode is enabled in `config.ini`.

Example:

```ini
DSTAR_ENABLED=1
P25_ENABLED=1
NXDN_ENABLED=1
```

Also confirm the related gateway/service is installed and configured on the DVSwitch side.

---

### If Web Login Does Not Work

Check:

```bash
grep -nE 'ALLTUNE2_AUTH_ENABLED|ALLTUNE2_ADMIN_USER|ALLTUNE2_ADMIN_PASSWORD_HASH' /var/www/html/alltune2/config.ini
```

To set/change the password:

```bash
sudo /var/www/html/alltune2/setup_alltune2.sh --set-admin-password
```

To disable login:

```bash
sudo /var/www/html/alltune2/setup_alltune2.sh --disable-auth
```

If the browser seems stuck in an old login state, close the browser tab or clear site data for the AllTune2 hostname.

---

### If HTTPS Shows a Certificate Warning

Check what certificate is being served:

```bash
openssl s_client -connect your-hostname:443 -servername your-hostname </dev/null 2>/dev/null \
  | openssl x509 -noout -subject -issuer -dates -ext subjectAltName
```

If the certificate says `node.local`, `node67040.local`, or `snakeoil`, Apache is still serving a self-signed certificate.

Use a DDNS/domain hostname with a trusted certificate, or use Tailscale/VPN.

---

### If an Update Behaves Strangely

Run setup again:

```bash
sudo /var/www/html/alltune2/setup_alltune2.sh
```

Then reload Apache if needed:

```bash
sudo systemctl reload apache2
```

If still strange, reboot:

```bash
sudo reboot
```

---

## 🧠 Simple Rules

- Do not commit `config.ini`.
- Do not commit `data/favorites.txt`.
- Do not commit backup files.
- Do not post passwords publicly.
- Do not expose AllTune2 publicly without web login enabled.
- Prefer Tailscale/VPN for outside access.
- If using public browser access, use DDNS/domain plus trusted HTTPS.
- Run normal setup after updates.
- Use `--set-admin-password` only when changing the web login password.
- Use `--disable-auth` only when turning login off.
- Test after every update.

---

## ✅ Done

After setup, open:

```text
/alltune2/public/
```

Then test the modes you use:

- BrandMeister
- TGIF
- YSF
- D-Star
- P25
- NXDN
- AllStarLink
- EchoLink

If web login is enabled, also test:

- View Only mode
- Login
- Signed In controls
- Logout
- disabled controls while logged out

---

## Contact

Project by Terry Claiborne / KC3KMV.

GitHub:

```text
https://github.com/TerryClaiborne/alltune2
```

---

## ⚠️ Important Update Notes

For normal updates:

```bash
cd /var/www/html/alltune2
sudo git pull origin main
sudo /var/www/html/alltune2/setup_alltune2.sh
```

Normal setup/update preserves:

- `config.ini`
- `data/favorites.txt`
- TGIF/HBLink config
- web login settings
- saved password hash

For web login password changes:

```bash
sudo /var/www/html/alltune2/setup_alltune2.sh --set-admin-password
```

For disabling web login:

```bash
sudo /var/www/html/alltune2/setup_alltune2.sh --disable-auth
```

Do not manually create password hashes unless you are doing advanced recovery. Normal users should let setup create the hash automatically.
