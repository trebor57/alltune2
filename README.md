# AllTune2

A modern, web-based control center for DVSwitch / AllStarLink systems.

AllTune2 provides a simple, reliable interface to connect, monitor, and switch between:

- BrandMeister (BM)
- TGIF (via integrated HBLink)
- YSF (System Fusion)
- AllStarLink
- EchoLink

The goal of this project is to provide a clean, easy-to-use interface while maintaining real backend reliability.

---

## 🚀 Current Status (April 2026)

All major modes are now fully working:

- BrandMeister (one-step connect + fast talkgroup switching)
- TGIF (via integrated HBLink backend)
- YSF (stable DVSwitch path)
- AllStarLink / EchoLink
- Seamless switching between modes
- Working audio path across all modes

---

## 🔥 Major Update: TGIF via HBLink

TGIF is now implemented using a dedicated HBLink backend instead of the traditional DVSwitch-only path.

### What this means:

- TGIF is stable and reliable
- Uses a local Python-based HBLink bridge
- Fully integrated into AllTune2 UI
- One-step connect (like BrandMeister)
- Supports talkgroup switching via backend helper
- Proper connect / disconnect behavior

---

## 🧠 How It Works

AllTune2 uses multiple backend paths depending on the mode:

| Mode | Backend |
|------|--------|
| BrandMeister | Local STFU-based receive helper |
| TGIF | HBLink (Python bridge + helper script) |
| YSF | DVSwitch native path |
| AllStarLink | Asterisk |
| EchoLink | Asterisk |

---

## 📦 Installation

### Requirements

- Debian 12 (Bookworm) or Debian 13 (Trixie)
- DVSwitch installed and working
- Asterisk (AllStarLink)
- Analog_Bridge and MMDVM_Bridge configured
- sudo access

---

### Install Steps

Clone the repository:

```
cd /var/www/html
git clone https://github.com/YOUR_REPO/alltune2.git
cd alltune2
```

Run the installer:

```
sudo ./setup_alltune2.sh
```

---

## ⚠️ IMPORTANT CONFIGURATION

### 1. config.ini

Location:
```
/var/www/html/alltune2/config.ini
```

Set:
```
MYNODE=YOUR_NODE
DVSWITCH_NODE=YOUR_DVSWITCH_NODE
BM_SelfcarePassword=YOUR_PASSWORD
TGIF_HotspotSecurityKey=YOUR_KEY
```

---

### 2. TGIF / HBLink Configuration

Location:
```
/var/www/html/alltune2/tgif-hblink/hblink.cfg
```

You MUST:
- Set your DMR ID
- Set hotspot/repeater-style ID if required
- Set TGIF/HBLink password/passphrase
- Verify ports and addresses

If this file is wrong, TGIF will not work.

---

### 3. External System Files

These must already be correct:

- /opt/MMDVM_Bridge/MMDVM_Bridge.ini
- /opt/Analog_Bridge/Analog_Bridge.ini
- /opt/MMDVM_Bridge/DVSwitch.ini

---

## 🔐 Security Notes

These files are NOT included in the repository and must be configured locally:

- config.ini
- tgif-hblink/hblink.cfg

---

## 🧪 Testing

After installation:

1. Open your browser:
   http://YOUR_NODE_IP/alltune2/public/

2. Test:
   - BrandMeister connect and TG change
   - TGIF connect and TG change
   - YSF connect
   - Switching between all modes
   - Disconnect DVSwitch
   - Disconnect All

---

## 🧭 Project Direction

- Clean, stable control center
- Reliable backend switching
- Minimal user configuration where possible
- GitHub-ready installation

---

## ⚠️ Notes

- TGIF startup may take a few seconds while HBLink initializes
- Audio path depends on Analog_Bridge being active
- Do not modify system-level DVSwitch files unless necessary

---

## 📄 License

This project is provided as-is for amateur radio use.
