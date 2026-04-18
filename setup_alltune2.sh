#!/usr/bin/env bash
set -euo pipefail

APP_NAME="AllTune2"
APP_DIR="/var/www/html/alltune2"
PUBLIC_DIR="$APP_DIR/public"
ASSETS_DIR="$PUBLIC_DIR/assets"
CSS_DIR="$ASSETS_DIR/css"
JS_DIR="$ASSETS_DIR/js"
API_DIR="$APP_DIR/api"
APP_CODE_DIR="$APP_DIR/app"
DATA_DIR="$APP_DIR/data"
DOCS_DIR="$APP_DIR/docs"
LOGS_DIR="$APP_DIR/logs"
RUN_DIR="$APP_DIR/run"
LOCAL_STFU_DIR="$APP_DIR/stfu"
TGIF_DIR="$APP_DIR/tgif-hblink"

CONFIG_FILE="$APP_DIR/config.ini"
CONFIG_EXAMPLE_FILE="$APP_DIR/config.ini.example"
FAVORITES_FILE="$DATA_DIR/favorites.txt"
VERSION_FILE="$APP_DIR/VERSION"

BM_RECEIVE_HELPER="$APP_DIR/alltune2-bm-receive.sh"
LOCAL_STFU_BIN="$LOCAL_STFU_DIR/STFU"

TGIF_HELPER="$TGIF_DIR/alltune2-hblink-audio-helper.sh"
TGIF_SET_TG="$TGIF_DIR/set_hblink_tg.sh"
TGIF_HBLINK_CFG="$TGIF_DIR/hblink.cfg"
TGIF_HBLINK_CFG_EXAMPLE="$TGIF_DIR/hblink.cfg.example"
TGIF_RULES_TEMPLATE="$TGIF_DIR/rules.py.template"
TGIF_RULES_FILE="$TGIF_DIR/rules.py"
TGIF_MMDVM_HBLINK_INI="$TGIF_DIR/MMDVM_Bridge.hblink.ini"
TGIF_MMDVM_PRE_HBLINK_INI="$TGIF_DIR/MMDVM_Bridge.pre-hblink.ini"
TGIF_REQUIREMENTS="$TGIF_DIR/requirements.txt"
TGIF_VENV_DIR="$TGIF_DIR/venv"
TGIF_VENV_PYTHON="$TGIF_VENV_DIR/bin/python"
TGIF_VENV_PIP="$TGIF_VENV_DIR/bin/pip"

WEB_USER="www-data"
WEB_GROUP="www-data"

ASTERISK_BIN="/usr/sbin/asterisk"
DVSWITCH_SH="/opt/MMDVM_Bridge/dvswitch.sh"
DVSWITCH_INI="/opt/MMDVM_Bridge/DVSwitch.ini"
MMDVM_BRIDGE_INI="/opt/MMDVM_Bridge/MMDVM_Bridge.ini"
ANALOG_BRIDGE_INI="/opt/Analog_Bridge/Analog_Bridge.ini"

ASTERISK_SUDOERS_FILE="/etc/sudoers.d/alltune2-asterisk"
BM_RECEIVE_SUDOERS_FILE="/etc/sudoers.d/alltune2-bm-receive"
TGIF_HELPER_SUDOERS_FILE="/etc/sudoers.d/alltune2-hblink"

EXPECTED_ASTERISK_SUDOERS_RULE="${WEB_USER} ALL=(root) NOPASSWD: ${ASTERISK_BIN}"
EXPECTED_BM_RECEIVE_SUDOERS_RULE="${WEB_USER} ALL=(root) NOPASSWD: ${BM_RECEIVE_HELPER}"
EXPECTED_TGIF_HELPER_SUDOERS_RULE="${WEB_USER} ALL=(root) NOPASSWD: ${TGIF_HELPER}"

log() {
    echo "[INFO] $*"
}

warn() {
    echo "[WARN] $*" >&2
}

fail() {
    echo "[ERROR] $*" >&2
    exit 1
}

require_root() {
    if [[ "${EUID}" -ne 0 ]]; then
        fail "Run this script as root."
    fi
}

require_app_dir() {
    if [[ ! -d "$APP_DIR" ]]; then
        fail "Application directory not found: $APP_DIR"
    fi
}

check_runtime_tools() {
    log "Checking runtime tools..."
    command -v php >/dev/null 2>&1 || fail "php is not installed or not in PATH."
    command -v sudo >/dev/null 2>&1 || fail "sudo is not installed or not in PATH."
    command -v visudo >/dev/null 2>&1 || fail "visudo is not installed or not in PATH."
    command -v python3 >/dev/null 2>&1 || fail "python3 is not installed or not in PATH."

    if python3 -m venv --help >/dev/null 2>&1; then
        log "python3 venv support found."
    else
        fail "python3 venv support is not available. Install python3-venv first."
    fi

    if command -v apache2ctl >/dev/null 2>&1; then
        log "apache2ctl found."
    else
        warn "apache2ctl not found in PATH."
    fi
}

check_web_user() {
    if id "$WEB_USER" >/dev/null 2>&1; then
        log "Web user exists: $WEB_USER"
    else
        fail "Web user does not exist: $WEB_USER"
    fi
}

make_dirs() {
    log "Ensuring required directories exist..."
    mkdir -p "$PUBLIC_DIR" "$ASSETS_DIR" "$CSS_DIR" "$JS_DIR" "$API_DIR" "$APP_CODE_DIR"
    mkdir -p "$DATA_DIR" "$DOCS_DIR" "$LOGS_DIR" "$RUN_DIR" "$LOCAL_STFU_DIR" "$TGIF_DIR"
}

create_config_example() {
    if [[ ! -f "$CONFIG_EXAMPLE_FILE" ]]; then
        log "Creating config.ini.example..."
        cat > "$CONFIG_EXAMPLE_FILE" <<'EOF'
MYNODE="YOUR NODE"
DVSWITCH_NODE="YOUR DVSWITCH NODE"
BM_SelfcarePassword="CHANGE_ME"
TGIF_HotspotSecurityKey="CHANGE_ME"
EOF
    else
        log "config.ini.example already exists."
    fi

    chmod 0644 "$CONFIG_EXAMPLE_FILE"
    chown root:root "$CONFIG_EXAMPLE_FILE"
}

create_config_if_missing() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        log "config.ini not found. Creating starter config.ini..."
        cat > "$CONFIG_FILE" <<'EOF'
MYNODE="YOUR NODE"
DVSWITCH_NODE="YOUR DVSWITCH NODE"
BM_SelfcarePassword="CHANGE_ME"
TGIF_HotspotSecurityKey="CHANGE_ME"
EOF
        warn "Created $CONFIG_FILE with placeholder values. Edit it before using AllTune2."
    else
        log "config.ini already exists. Preserving current values."
    fi

    chmod 0640 "$CONFIG_FILE"
    chown root:"$WEB_GROUP" "$CONFIG_FILE"
}

create_favorites_if_missing() {
    if [[ ! -f "$FAVORITES_FILE" ]]; then
        log "Creating shared favorites file..."
        cat > "$FAVORITES_FILE" <<'EOF'
9990|Parrot|TGIF Parrot|TGIF
9050|East Coast Reflector|East Coast TGIF|TGIF
23510|CQ-UK World Wide|CQ-World Wide TGIF|TGIF
311630|AA9JR Repeater Link|Morning Net|TGIF
19570|Example TGIF|Example Favorite|TGIF
3220008|Example BM|Example Favorite|BM
68064|Example AllStar|Example AllStar Node|ASL
parrot.ysfreflector.de:42020|Fusion|Parrot For Fusion|YSF
EOF
    else
        log "favorites.txt already exists. Preserving current contents."
    fi

    chmod 0664 "$FAVORITES_FILE"
    chown "$WEB_USER":"$WEB_GROUP" "$FAVORITES_FILE"
}

create_tgif_hblink_cfg_example() {
    if [[ -f "$TGIF_HBLINK_CFG_EXAMPLE" ]]; then
        log "hblink.cfg.example already exists."
        chmod 0644 "$TGIF_HBLINK_CFG_EXAMPLE"
        chown root:root "$TGIF_HBLINK_CFG_EXAMPLE"
        return
    fi

    if [[ -f "$TGIF_HBLINK_CFG" ]]; then
        log "Creating hblink.cfg.example from current hblink.cfg..."
        cp -f "$TGIF_HBLINK_CFG" "$TGIF_HBLINK_CFG_EXAMPLE"

        python3 - "$TGIF_HBLINK_CFG_EXAMPLE" <<'PY'
import pathlib
import re
import sys

path = pathlib.Path(sys.argv[1])
text = path.read_text()

patterns = [
    (r'(^\s*PASSPHRASE\s*=\s*).*$' , r'\1CHANGE_ME', re.MULTILINE),
    (r'(^\s*PASSWORD\s*=\s*).*$'   , r'\1CHANGE_ME', re.MULTILINE),
    (r'(^\s*TGID_TS2_[0-9]+\s*=\s*).*$' , r'\1CHANGE_ME', re.MULTILINE),
]

for pattern, repl, flags in patterns:
    text = re.sub(pattern, repl, text, flags=flags)

path.write_text(text)
PY
        warn "Created $TGIF_HBLINK_CFG_EXAMPLE from live hblink.cfg. Review and sanitize it before pushing to GitHub."
    else
        log "Creating starter hblink.cfg.example..."
        cat > "$TGIF_HBLINK_CFG_EXAMPLE" <<'EOF'
# Review this file and replace all placeholder values before using TGIF/HBLink.
# The exact keys/sections here must match your local HBLink runtime files.
#
# Important:
# - Set the correct callsign / repeater / radio ID fields.
# - Set the correct hotspot / repeater-style DMR ID where required.
# - Set the TGIF/HBLink passphrase / password fields.
# - Verify ports and addresses match your system.

[GLOBAL]
PATH=.

[REPORTS]
REPORT=False
REPORT_INTERVAL=60
REPORT_PORT=4321
REPORT_CLIENTS=127.0.0.1

# Replace all CHANGE_ME values below with your real local settings.
EOF
    fi

    chmod 0644 "$TGIF_HBLINK_CFG_EXAMPLE"
    chown root:root "$TGIF_HBLINK_CFG_EXAMPLE"
}

create_tgif_hblink_cfg_if_missing() {
    if [[ -f "$TGIF_HBLINK_CFG" ]]; then
        log "Live hblink.cfg already exists. Preserving current values."
    elif [[ -f "$TGIF_HBLINK_CFG_EXAMPLE" ]]; then
        log "Creating starter hblink.cfg from hblink.cfg.example..."
        cp -f "$TGIF_HBLINK_CFG_EXAMPLE" "$TGIF_HBLINK_CFG"
        warn "Created $TGIF_HBLINK_CFG with placeholder values. Edit it before using TGIF/HBLink."
    else
        fail "Neither $TGIF_HBLINK_CFG nor $TGIF_HBLINK_CFG_EXAMPLE exists."
    fi

    chmod 0640 "$TGIF_HBLINK_CFG"
    chown root:"$WEB_GROUP" "$TGIF_HBLINK_CFG"
}

check_required_repo_files() {
    log "Checking required repo files..."

    local required_files=(
        "$APP_DIR/README.md"
        "$APP_DIR/VERSION"
        "$APP_DIR/.gitignore"
        "$APP_DIR/setup_alltune2.sh"
        "$APP_DIR/alltune2-bm-receive.sh"
        "$APP_DIR/app/Support/Config.php"
        "$APP_DIR/api/connect.php"
        "$APP_DIR/api/status.php"
        "$APP_DIR/public/index.php"
        "$APP_DIR/public/favorites.php"
        "$APP_DIR/public/alltune2_ribbon_bar.php"
        "$APP_DIR/public/assets/js/app.js"
        "$APP_DIR/public/assets/css/style.css"
        "$CONFIG_EXAMPLE_FILE"
        "$LOCAL_STFU_BIN"
        "$TGIF_HELPER"
        "$TGIF_SET_TG"
        "$TGIF_DIR/bridge.py"
        "$TGIF_DIR/hblink.py"
        "$TGIF_DIR/config.py"
        "$TGIF_DIR/const.py"
        "$TGIF_DIR/log.py"
        "$TGIF_DIR/reporting_const.py"
        "$TGIF_MMDVM_HBLINK_INI"
        "$TGIF_RULES_TEMPLATE"
        "$TGIF_REQUIREMENTS"
    )

    local missing=0
    local file

    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            warn "Missing required file: $file"
            missing=1
        fi
    done

    if [[ "$missing" -ne 0 ]]; then
        fail "Required AllTune2 repo files are missing."
    fi

    log "Required repo files look present."
}

check_optional_files() {
    log "Checking optional scaffold files..."

    local optional_files=(
        "$APP_DIR/tree.txt"
        "$APP_DIR/app/State/StatusMapper.php"
        "$APP_DIR/app/Actions/AllStarAction.php"
        "$APP_DIR/app/Actions/BrandMeisterAction.php"
        "$APP_DIR/app/Actions/TGIFAction.php"
        "$APP_DIR/app/Actions/YSFAction.php"
        "$TGIF_DIR/README.md"
        "$TGIF_DIR/README_START.txt"
    )

    local file
    for file in "${optional_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            warn "Optional file not found: $file"
        fi
    done
}

check_dvswitch_dependencies() {
    log "Checking DVSwitch system dependencies..."

    [[ -x "$DVSWITCH_SH" ]] || fail "Required DVSwitch helper not found or not executable: $DVSWITCH_SH"
    [[ -f "$DVSWITCH_INI" ]] || fail "Required DVSwitch.ini not found: $DVSWITCH_INI"
    [[ -f "$MMDVM_BRIDGE_INI" ]] || fail "Required MMDVM_Bridge.ini not found: $MMDVM_BRIDGE_INI"
    [[ -f "$ANALOG_BRIDGE_INI" ]] || fail "Required Analog_Bridge.ini not found: $ANALOG_BRIDGE_INI"

    log "DVSwitch dependencies look present."
}

check_helper_local_paths() {
    log "Checking BM receive helper local paths..."

    grep -q '^STFU_DIR="/var/www/html/alltune2/stfu"$' "$BM_RECEIVE_HELPER" \
        || fail "alltune2-bm-receive.sh is not pointed at the AllTune2-local STFU directory."

    grep -q '^STFU_BIN="/var/www/html/alltune2/stfu/STFU"$' "$BM_RECEIVE_HELPER" \
        || fail "alltune2-bm-receive.sh is not pointed at the AllTune2-local STFU binary."

    if grep -q '/usr/local/bin/STFU' "$BM_RECEIVE_HELPER"; then
        fail "alltune2-bm-receive.sh still references /usr/local/bin/STFU."
    fi

    if grep -q '/opt/STFU' "$BM_RECEIVE_HELPER"; then
        fail "alltune2-bm-receive.sh still references /opt/STFU."
    fi

    log "BM receive helper local STFU paths look correct."
}

ensure_tgif_runtime_local_files() {
    log "Ensuring TGIF/HBLink local runtime files exist..."

    if [[ ! -f "$TGIF_MMDVM_PRE_HBLINK_INI" ]]; then
        log "Creating initial MMDVM_Bridge.pre-hblink.ini from current system MMDVM_Bridge.ini..."
        cp -f "$MMDVM_BRIDGE_INI" "$TGIF_MMDVM_PRE_HBLINK_INI"
    else
        log "MMDVM_Bridge.pre-hblink.ini already exists. Preserving current file."
    fi

    chmod 0644 "$TGIF_MMDVM_PRE_HBLINK_INI"
    chown root:root "$TGIF_MMDVM_PRE_HBLINK_INI"

    if [[ ! -f "$TGIF_RULES_FILE" ]]; then
        log "rules.py not found. Generating an initial rules.py from rules.py.template if possible..."
        if [[ -x "$TGIF_SET_TG" ]]; then
            if "$TGIF_SET_TG" 9990 "$TGIF_DIR" >/dev/null 2>&1; then
                log "Generated initial rules.py with placeholder TG 9990. It will be updated dynamically by the helper."
            else
                warn "Could not generate initial rules.py automatically. The TGIF helper will generate it later."
            fi
        else
            warn "set_hblink_tg.sh is not executable yet; rules.py will be generated later."
        fi
    fi
}

build_tgif_venv() {
    log "Ensuring TGIF/HBLink Python virtual environment exists..."

    if [[ ! -x "$TGIF_VENV_PYTHON" ]]; then
        log "Creating TGIF/HBLink virtual environment at $TGIF_VENV_DIR..."
        python3 -m venv "$TGIF_VENV_DIR"
    else
        log "TGIF/HBLink virtual environment already exists."
    fi

    if [[ ! -x "$TGIF_VENV_PYTHON" ]]; then
        fail "Python is missing from the TGIF/HBLink virtual environment: $TGIF_VENV_PYTHON"
    fi

    if [[ ! -x "$TGIF_VENV_PIP" ]]; then
        log "pip is missing from the TGIF/HBLink virtual environment. Bootstrapping with ensurepip..."
        "$TGIF_VENV_PYTHON" -m ensurepip --upgrade >/dev/null 2>&1 || true
    fi

    if [[ ! -x "$TGIF_VENV_PIP" ]]; then
        log "pip still missing after ensurepip. Rebuilding the TGIF/HBLink virtual environment..."
        rm -rf "$TGIF_VENV_DIR"
        python3 -m venv "$TGIF_VENV_DIR"
    fi

    if [[ ! -x "$TGIF_VENV_PIP" ]]; then
        fail "pip is still missing from the TGIF/HBLink virtual environment after rebuild: $TGIF_VENV_PIP"
    fi

    log "Installing TGIF/HBLink Python requirements..."
    "$TGIF_VENV_PIP" install --upgrade pip >/dev/null
    "$TGIF_VENV_PIP" install -r "$TGIF_REQUIREMENTS"
}

set_permissions() {
    log "Setting ownership and permissions..."

    find "$APP_DIR" -type d -exec chmod 0755 {} \;
    find "$APP_DIR" -type f -exec chmod 0644 {} \;

    chown -R root:root "$APP_DIR"

    chmod 0755 "$APP_DIR/setup_alltune2.sh"
    chmod 0755 "$BM_RECEIVE_HELPER"
    chmod 0755 "$LOCAL_STFU_BIN"
    chmod 0755 "$TGIF_HELPER"
    chmod 0755 "$TGIF_SET_TG"

    chown root:root "$APP_DIR/setup_alltune2.sh"
    chown root:root "$BM_RECEIVE_HELPER"
    chown root:root "$LOCAL_STFU_BIN"
    chown root:root "$TGIF_HELPER"
    chown root:root "$TGIF_SET_TG"

    chmod 0775 "$DATA_DIR"
    chown "$WEB_USER":"$WEB_GROUP" "$DATA_DIR"

    chmod 0775 "$LOGS_DIR"
    chown "$WEB_USER":"$WEB_GROUP" "$LOGS_DIR"

    chmod 0775 "$RUN_DIR"
    chown "$WEB_USER":"$WEB_GROUP" "$RUN_DIR"

    chmod 0664 "$FAVORITES_FILE"
    chown "$WEB_USER":"$WEB_GROUP" "$FAVORITES_FILE"

    chmod 0640 "$CONFIG_FILE"
    chown root:"$WEB_GROUP" "$CONFIG_FILE"

    chmod 0644 "$CONFIG_EXAMPLE_FILE"
    chown root:root "$CONFIG_EXAMPLE_FILE"

    chmod 0640 "$TGIF_HBLINK_CFG"
    chown root:"$WEB_GROUP" "$TGIF_HBLINK_CFG"

    chmod 0644 "$TGIF_HBLINK_CFG_EXAMPLE"
    chown root:root "$TGIF_HBLINK_CFG_EXAMPLE"

    if [[ -d "$TGIF_VENV_DIR" ]]; then
        chown -R root:root "$TGIF_VENV_DIR"
    fi
}

create_or_update_sudoers_files() {
    log "Ensuring required sudoers rules exist..."

    [[ -x "$ASTERISK_BIN" ]] || fail "Asterisk binary not found at $ASTERISK_BIN"
    [[ -x "$BM_RECEIVE_HELPER" ]] || fail "BM receive helper is not executable: $BM_RECEIVE_HELPER"
    [[ -x "$TGIF_HELPER" ]] || fail "TGIF helper is not executable: $TGIF_HELPER"

    cat > "$ASTERISK_SUDOERS_FILE" <<EOF
$EXPECTED_ASTERISK_SUDOERS_RULE
EOF

    cat > "$BM_RECEIVE_SUDOERS_FILE" <<EOF
$EXPECTED_BM_RECEIVE_SUDOERS_RULE
EOF

    cat > "$TGIF_HELPER_SUDOERS_FILE" <<EOF
$EXPECTED_TGIF_HELPER_SUDOERS_RULE
EOF

    chmod 0440 "$ASTERISK_SUDOERS_FILE" "$BM_RECEIVE_SUDOERS_FILE" "$TGIF_HELPER_SUDOERS_FILE"

    visudo -cf "$ASTERISK_SUDOERS_FILE" >/dev/null || fail "visudo validation failed for $ASTERISK_SUDOERS_FILE"
    visudo -cf "$BM_RECEIVE_SUDOERS_FILE" >/dev/null || fail "visudo validation failed for $BM_RECEIVE_SUDOERS_FILE"
    visudo -cf "$TGIF_HELPER_SUDOERS_FILE" >/dev/null || fail "visudo validation failed for $TGIF_HELPER_SUDOERS_FILE"

    log "Sudoers files created and validated."
}

check_php_syntax() {
    log "Running PHP syntax checks..."

    local php_files=(
        "$APP_DIR/app/Support/Config.php"
        "$APP_DIR/api/connect.php"
        "$APP_DIR/api/status.php"
        "$APP_DIR/public/index.php"
        "$APP_DIR/public/favorites.php"
        "$APP_DIR/public/alltune2_ribbon_bar.php"
    )

    local file
    for file in "${php_files[@]}"; do
        if [[ -f "$file" ]]; then
            php -l "$file" >/dev/null || fail "PHP syntax check failed: $file"
        fi
    done

    log "PHP syntax checks passed."
}

check_shell_syntax() {
    log "Running shell syntax checks..."

    bash -n "$APP_DIR/setup_alltune2.sh" || fail "Shell syntax check failed: $APP_DIR/setup_alltune2.sh"
    bash -n "$BM_RECEIVE_HELPER" || fail "Shell syntax check failed: $BM_RECEIVE_HELPER"
    bash -n "$TGIF_HELPER" || fail "Shell syntax check failed: $TGIF_HELPER"
    bash -n "$TGIF_SET_TG" || fail "Shell syntax check failed: $TGIF_SET_TG"

    log "Shell syntax checks passed."
}

check_python_syntax() {
    log "Running Python syntax checks for TGIF/HBLink..."

    local py_files=(
        "$TGIF_DIR/bridge.py"
        "$TGIF_DIR/hblink.py"
        "$TGIF_DIR/config.py"
        "$TGIF_DIR/const.py"
        "$TGIF_DIR/log.py"
        "$TGIF_DIR/reporting_const.py"
        "$TGIF_DIR/voice_lib.py"
    )

    local file
    for file in "${py_files[@]}"; do
        if [[ -f "$file" ]]; then
            python3 -m py_compile "$file" || fail "Python syntax check failed: $file"
        fi
    done

    log "Python syntax checks passed."
}

check_config_content() {
    log "Checking config.ini keys..."

    local required_keys=(
        "MYNODE"
        "DVSWITCH_NODE"
        "BM_SelfcarePassword"
        "TGIF_HotspotSecurityKey"
    )

    local missing=0
    local key

    for key in "${required_keys[@]}"; do
        if ! grep -qE "^[[:space:]]*${key}[[:space:]]*=" "$CONFIG_FILE"; then
            warn "Missing config key in $CONFIG_FILE: $key"
            missing=1
        fi
    done

    if [[ "$missing" -eq 0 ]]; then
        log "Required config keys appear present."
    else
        warn "config.ini is missing one or more required keys."
    fi
}

warn_if_placeholder_values_remain() {
    log "Checking for placeholder values..."

    local placeholders_regex='YOUR NODE|YOUR DVSWITCH NODE|CHANGE_ME|YOUR_REAL_PASSWORD|YOUR_REAL_KEY|YOUR PASSWORD|YOUR KEY'

    if grep -Eq "$placeholders_regex" "$CONFIG_FILE"; then
        warn "config.ini still contains placeholder values. BM/TGIF/YSF may not work until it is edited."
    fi

    if grep -Eq "$placeholders_regex" "$TGIF_HBLINK_CFG"; then
        warn "hblink.cfg still contains placeholder values. TGIF/HBLink will not work until it is edited."
    fi

    if ! grep -Eq 'MYNODE[[:space:]]*=' "$CONFIG_FILE"; then
        warn "config.ini does not define MYNODE."
    fi

    if ! grep -Eq 'DVSWITCH_NODE[[:space:]]*=' "$CONFIG_FILE"; then
        warn "config.ini does not define DVSWITCH_NODE."
    fi
}

check_external_config_hints() {
    log "Checking external system config hints..."

    if ! grep -qE '^[[:space:]]*gatewayDmrId[[:space:]]*=' "$ANALOG_BRIDGE_INI"; then
        warn "Analog_Bridge.ini does not contain gatewayDmrId. Local TG generation may fail."
    fi

    if ! grep -qE '^[[:space:]]*txTg[[:space:]]*=' "$ANALOG_BRIDGE_INI"; then
        warn "Analog_Bridge.ini does not contain txTg. Local TG fallback may fail."
    fi

    if ! grep -qE '^[[:space:]]*BMPassword[[:space:]]*=' "$DVSWITCH_INI"; then
        warn "DVSwitch.ini does not contain BMPassword. BM receive mode may not work."
    fi

    warn "Review TGIF/HBLink identity fields carefully. Systems often require both a base DMR ID and a hotspot/repeater-style suffixed radio ID in the HBLink/MMDVM config files."
}

check_sudoers_requirement() {
    log "Checking installed sudoers files..."

    grep -qF "$EXPECTED_ASTERISK_SUDOERS_RULE" "$ASTERISK_SUDOERS_FILE" \
        || fail "Expected Asterisk sudoers rule not found in $ASTERISK_SUDOERS_FILE"

    grep -qF "$EXPECTED_BM_RECEIVE_SUDOERS_RULE" "$BM_RECEIVE_SUDOERS_FILE" \
        || fail "Expected BM receive sudoers rule not found in $BM_RECEIVE_SUDOERS_FILE"

    grep -qF "$EXPECTED_TGIF_HELPER_SUDOERS_RULE" "$TGIF_HELPER_SUDOERS_FILE" \
        || fail "Expected TGIF helper sudoers rule not found in $TGIF_HELPER_SUDOERS_FILE"

    visudo -cf "$ASTERISK_SUDOERS_FILE" >/dev/null || fail "Sudoers file failed validation: $ASTERISK_SUDOERS_FILE"
    visudo -cf "$BM_RECEIVE_SUDOERS_FILE" >/dev/null || fail "Sudoers file failed validation: $BM_RECEIVE_SUDOERS_FILE"
    visudo -cf "$TGIF_HELPER_SUDOERS_FILE" >/dev/null || fail "Sudoers file failed validation: $TGIF_HELPER_SUDOERS_FILE"

    log "Installed sudoers files look correct."
}

check_status_endpoint_cli() {
    log "Checking status endpoint through CLI..."

    if php "$APP_DIR/api/status.php" >/dev/null 2>&1; then
        log "CLI execution of api/status.php succeeded."
    else
        warn "CLI execution of api/status.php returned a non-zero status."
    fi
}

check_tgif_helper_cli() {
    log "Checking TGIF helper through CLI..."

    local output
    if output="$(sudo "$TGIF_HELPER" status 2>&1)"; then
        if [[ "$output" == *'"action": "status"'* ]]; then
            log "TGIF helper CLI status check returned JSON."
        else
            warn "TGIF helper CLI status check returned unexpected output."
        fi
    else
        warn "TGIF helper CLI status check returned a non-zero status."
        warn "$output"
    fi
}

show_summary() {
    local version="unknown"

    if [[ -f "$VERSION_FILE" ]]; then
        version="$(tr -d '\r\n' < "$VERSION_FILE")"
    fi

    echo
    echo "========================================"
    echo "$APP_NAME setup summary"
    echo "========================================"
    echo "Version:              ${version}"
    echo "App directory:        $APP_DIR"
    echo "Config file:          $CONFIG_FILE"
    echo "Config example:       $CONFIG_EXAMPLE_FILE"
    echo "Favorites file:       $FAVORITES_FILE"
    echo "BM helper:            $BM_RECEIVE_HELPER"
    echo "Local STFU binary:    $LOCAL_STFU_BIN"
    echo "TGIF helper:          $TGIF_HELPER"
    echo "TGIF cfg:             $TGIF_HBLINK_CFG"
    echo "TGIF cfg example:     $TGIF_HBLINK_CFG_EXAMPLE"
    echo "TGIF venv:            $TGIF_VENV_DIR"
    echo "TGIF restore ini:     $TGIF_MMDVM_PRE_HBLINK_INI"
    echo "Web user/group:       $WEB_USER:$WEB_GROUP"
    echo "Asterisk sudoers:     $ASTERISK_SUDOERS_FILE"
    echo "BM helper sudoers:    $BM_RECEIVE_SUDOERS_FILE"
    echo "TGIF helper sudoers:  $TGIF_HELPER_SUDOERS_FILE"
    echo

    echo "Notes:"
    echo "- Existing config.ini, favorites.txt, hblink.cfg, and MMDVM_Bridge.pre-hblink.ini are preserved."
    echo "- BM is one-step and uses the AllTune2-local BM receive helper."
    echo "- TGIF uses the AllTune2-local HBLink helper and Python venv."
    echo "- The installer does not overwrite /opt/MMDVM_Bridge/MMDVM_Bridge.ini, /opt/MMDVM_Bridge/DVSwitch.ini, or /opt/Analog_Bridge/Analog_Bridge.ini."
    echo "- TGIF/HBLink often needs both a base DMR ID and a hotspot/repeater-style suffixed radio ID in the HBLink/MMDVM config path."
    echo "- Review hblink.cfg carefully. Wrong values there can make TGIF fail even when the helper and web files are correct."
    echo

    echo "Next steps:"
    echo "1. Edit $CONFIG_FILE and set real values if needed."
    echo "2. Edit $TGIF_HBLINK_CFG and verify TGIF/HBLink identity/auth values."
    echo "3. Review $TGIF_MMDVM_HBLINK_INI for local port/address expectations."
    echo "4. Confirm external system files are correct:"
    echo "   - $DVSWITCH_INI"
    echo "   - $MMDVM_BRIDGE_INI"
    echo "   - $ANALOG_BRIDGE_INI"
    echo "5. Open /alltune2/public/ in the browser."
    echo "6. Test BM, TGIF, YSF, AllStarLink, EchoLink, Disconnect DVSwitch, and Disconnect All."
    echo
}

main() {
    require_root
    require_app_dir
    check_runtime_tools
    check_web_user
    make_dirs
    create_config_example
    create_config_if_missing
    create_favorites_if_missing
    create_tgif_hblink_cfg_example
    create_tgif_hblink_cfg_if_missing
    check_required_repo_files
    check_optional_files
    check_dvswitch_dependencies
    check_helper_local_paths
    ensure_tgif_runtime_local_files
    build_tgif_venv
    set_permissions
    create_or_update_sudoers_files
    check_php_syntax
    check_shell_syntax
    check_python_syntax
    check_config_content
    warn_if_placeholder_values_remain
    check_external_config_hints
    check_sudoers_requirement
    check_status_endpoint_cli
    check_tgif_helper_cli
    show_summary
}

main "$@"
