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
TGIF_MMDVM_HBLINK_INI_EXAMPLE="$TGIF_DIR/MMDVM_Bridge.hblink.ini.example"
TGIF_MMDVM_PRE_HBLINK_INI="$TGIF_DIR/MMDVM_Bridge.pre-hblink.ini"
TGIF_REQUIREMENTS="$TGIF_DIR/requirements.txt"
TGIF_VENV_DIR="$TGIF_DIR/venv"
TGIF_VENV_PYTHON="$TGIF_VENV_DIR/bin/python"
TGIF_VENV_PIP="$TGIF_VENV_DIR/bin/pip"
TGIF_REQUIREMENTS_STATE_FILE="$TGIF_VENV_DIR/.alltune2_requirements.sha256"

WEB_USER="www-data"
WEB_GROUP="www-data"
INSTALLER_MODE="${INSTALLER_MODE:-quiet}"

ASTERISK_BIN="/usr/sbin/asterisk"
DVSWITCH_SH="/opt/MMDVM_Bridge/dvswitch.sh"
DVSWITCH_INI="/opt/MMDVM_Bridge/DVSwitch.ini"
MMDVM_BRIDGE_INI="/opt/MMDVM_Bridge/MMDVM_Bridge.ini"
ANALOG_BRIDGE_INI="/opt/Analog_Bridge/Analog_Bridge.ini"

ASTERISK_SUDOERS_FILE="/etc/sudoers.d/alltune2-asterisk"
BM_RECEIVE_SUDOERS_FILE="/etc/sudoers.d/alltune2-bm-receive"
TGIF_HELPER_SUDOERS_FILE="/etc/sudoers.d/alltune2-hblink"

BM_RECEIVE_LOG_FILE="/var/log/alltune2-bm-receive.log"
BM_RECEIVE_LOGROTATE_FILE="/etc/logrotate.d/alltune2-bm-receive"
STFU_LOG_FILE="/var/log/STFU.log"
BM_STFU_LOG_FILE="/var/log/bm-stfu.log"
STFU_LOGROTATE_FILE="/etc/logrotate.d/alltune2-stfu"
APACHE_SECURITY_CONF_NAME="alltune2-security"
APACHE_SECURITY_CONF_FILE="/etc/apache2/conf-available/${APACHE_SECURITY_CONF_NAME}.conf"

EXPECTED_ASTERISK_SUDOERS_RULE="${WEB_USER} ALL=(root) NOPASSWD: ${ASTERISK_BIN}"
EXPECTED_BM_RECEIVE_SUDOERS_RULE="${WEB_USER} ALL=(root) NOPASSWD: ${BM_RECEIVE_HELPER}"
EXPECTED_TGIF_HELPER_SUDOERS_RULE="${WEB_USER} ALL=(root) NOPASSWD: ${TGIF_HELPER}"

validate_installer_mode() {
    case "$INSTALLER_MODE" in
        quiet|verbose) ;;
        *)
            fail "INSTALLER_MODE must be 'quiet' or 'verbose'."
            ;;
    esac
}

log() {
    if [[ "$INSTALLER_MODE" == "verbose" ]]; then
        echo "[INFO] $*"
    fi
}

step() {
    echo "[STEP] $*"
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
        log "hblink.cfg.example already exists. Preserving repo example file."
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

create_tgif_mmdvm_hblink_ini_if_missing() {
    if [[ -f "$TGIF_MMDVM_HBLINK_INI" ]]; then
        log "Live MMDVM_Bridge.hblink.ini already exists. Preserving current values."
    elif [[ -f "$TGIF_MMDVM_HBLINK_INI_EXAMPLE" ]]; then
        log "Creating starter MMDVM_Bridge.hblink.ini from MMDVM_Bridge.hblink.ini.example..."
        cp -f "$TGIF_MMDVM_HBLINK_INI_EXAMPLE" "$TGIF_MMDVM_HBLINK_INI"
        warn "Created $TGIF_MMDVM_HBLINK_INI with placeholder/example values. Review it before using TGIF/HBLink."
    else
        fail "Neither $TGIF_MMDVM_HBLINK_INI nor $TGIF_MMDVM_HBLINK_INI_EXAMPLE exists."
    fi

    chmod 0640 "$TGIF_MMDVM_HBLINK_INI"
    chown root:"$WEB_GROUP" "$TGIF_MMDVM_HBLINK_INI"
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
        "$APP_DIR/api/direct_link.php"
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
        "$TGIF_MMDVM_HBLINK_INI_EXAMPLE"
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

    grep -q '^STFU_DIR="/var/www/html/alltune2/stfu"$' "$BM_RECEIVE_HELPER"         || fail "alltune2-bm-receive.sh is not pointed at the AllTune2-local STFU directory."

    grep -q '^STFU_BIN="/var/www/html/alltune2/stfu/STFU"$' "$BM_RECEIVE_HELPER"         || fail "alltune2-bm-receive.sh is not pointed at the AllTune2-local STFU binary."

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


validate_json_file() {
    local file="$1"

    python3 - "$file" <<'JSONPY'
import json
import pathlib
import sys

path = pathlib.Path(sys.argv[1])

try:
    with path.open('r', encoding='utf-8') as handle:
        json.load(handle)
except Exception as exc:
    print(str(exc), file=sys.stderr)
    sys.exit(1)
JSONPY
}

move_bad_tgif_alias_file_aside() {
    local file="$1"
    local reason="$2"
    local timestamp
    local backup_file

    timestamp="$(date +%Y%m%d-%H%M%S)"
    backup_file="${file}.bad-${timestamp}"

    warn "TGIF/HBLink alias file is ${reason}: ${file}"
    warn "Moving bad alias file aside: ${backup_file}"

    mv -f "$file" "$backup_file"
    chmod 0644 "$backup_file" 2>/dev/null || true
    chown root:root "$backup_file" 2>/dev/null || true
}

validate_tgif_alias_json_files() {
    log "Validating TGIF/HBLink alias JSON files..."

    local alias_files=(
        "$TGIF_DIR/peer_ids.json"
        "$TGIF_DIR/subscriber_ids.json"
        "$TGIF_DIR/talkgroup_ids.json"
    )

    local file

    for file in "${alias_files[@]}"; do
        if [[ ! -e "$file" ]]; then
            echo "[INFO] TGIF/HBLink alias file is not present yet. This is normal on some installs; it will be downloaded/regenerated when HBLink needs it: $file"
            continue
        fi

        if [[ ! -s "$file" ]]; then
            move_bad_tgif_alias_file_aside "$file" "missing data or zero bytes"
            continue
        fi

        if ! validate_json_file "$file" >/dev/null 2>&1; then
            move_bad_tgif_alias_file_aside "$file" "invalid JSON"
            continue
        fi

        chmod 0644 "$file"
        chown root:root "$file"
        log "TGIF/HBLink alias JSON looks valid: $file"
    done
}

requirements_hash() {
    python3 - "$TGIF_REQUIREMENTS" <<'PY'
import hashlib
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
print(hashlib.sha256(path.read_bytes()).hexdigest())
PY
}

check_tgif_requirements_present() {
    "$TGIF_VENV_PYTHON" - "$TGIF_REQUIREMENTS" <<'PY'
import importlib.metadata
import pathlib
import re
import sys

path = pathlib.Path(sys.argv[1])
missing = []
for raw_line in path.read_text().splitlines():
    line = raw_line.strip()
    if not line or line.startswith('#'):
        continue
    match = re.match(r'([A-Za-z0-9_.-]+)', line)
    if not match:
        missing.append(f"unsupported requirement format: {line}")
        continue
    name = match.group(1)
    normalized = name.replace('_', '-').lower()
    found = False
    for dist in importlib.metadata.distributions():
        dist_name = dist.metadata.get('Name', '')
        if dist_name.replace('_', '-').lower() == normalized:
            found = True
            break
    if not found:
        missing.append(name)
if missing:
    for item in missing:
        print(item)
    raise SystemExit(1)
PY
}

run_pip_requirements_install() {
    if [[ "$INSTALLER_MODE" == "verbose" ]]; then
        "$TGIF_VENV_PIP" install -r "$TGIF_REQUIREMENTS"
        return
    fi

    local pip_log=""
    pip_log="$(mktemp)"
    if "$TGIF_VENV_PIP" install -r "$TGIF_REQUIREMENTS" >"$pip_log" 2>&1; then
        rm -f "$pip_log"
        return
    fi

    cat "$pip_log" >&2
    rm -f "$pip_log"
    fail "TGIF/HBLink Python requirements install failed."
}

sync_tgif_requirements_if_needed() {
    log "Checking TGIF/HBLink Python environment..."

    local current_hash=""
    current_hash="$(requirements_hash)"

    local should_sync=0
    local reason=""

    if [[ "${TGIF_VENV_WAS_REBUILT:-0}" == "1" ]]; then
        should_sync=1
        reason="new or rebuilt virtual environment"
    elif [[ ! -f "$TGIF_REQUIREMENTS_STATE_FILE" ]]; then
        should_sync=1
        reason="requirements state file is missing"
    elif [[ "$(tr -d '\r\n' < "$TGIF_REQUIREMENTS_STATE_FILE")" != "$current_hash" ]]; then
        should_sync=1
        reason="requirements.txt changed"
    elif ! check_tgif_requirements_present >/dev/null 2>&1; then
        should_sync=1
        reason="one or more required Python packages are missing"
    elif ! "$TGIF_VENV_PIP" check >/dev/null 2>&1; then
        should_sync=1
        reason="pip dependency check failed"
    fi

    if [[ "$should_sync" -eq 1 ]]; then
        log "Installing TGIF/HBLink Python requirements because $reason..."
        run_pip_requirements_install
        "$TGIF_VENV_PIP" check >/dev/null || fail "pip dependency check failed after installing TGIF/HBLink requirements."
        printf '%s\n' "$current_hash" > "$TGIF_REQUIREMENTS_STATE_FILE"
        chmod 0644 "$TGIF_REQUIREMENTS_STATE_FILE"
        chown root:root "$TGIF_REQUIREMENTS_STATE_FILE"
    else
        log "TGIF/HBLink Python requirements already look satisfied. Skipping pip install."
    fi
}

build_tgif_venv() {
    log "Ensuring TGIF/HBLink Python virtual environment exists..."

    TGIF_VENV_WAS_REBUILT=0

    if [[ ! -x "$TGIF_VENV_PYTHON" ]]; then
        log "Creating TGIF/HBLink virtual environment at $TGIF_VENV_DIR..."
        rm -rf "$TGIF_VENV_DIR"
        python3 -m venv "$TGIF_VENV_DIR"
        TGIF_VENV_WAS_REBUILT=1
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
        TGIF_VENV_WAS_REBUILT=1
    fi

    if [[ ! -x "$TGIF_VENV_PIP" ]]; then
        fail "pip is still missing from the TGIF/HBLink virtual environment after rebuild: $TGIF_VENV_PIP"
    fi

    sync_tgif_requirements_if_needed
}

set_tree_mode_and_owner() {
    local base_dir="$1"
    local dir_mode="$2"
    local file_mode="$3"
    local owner="$4"
    local group="$5"
    local exclude_dir="${6:-}"

    [[ -d "$base_dir" ]] || return 0

    if [[ -n "$exclude_dir" && -d "$exclude_dir" ]]; then
        find "$base_dir" -path "$exclude_dir" -prune -o -type d -exec chmod "$dir_mode" {} +
        find "$base_dir" -path "$exclude_dir" -prune -o -type f -exec chmod "$file_mode" {} +
        find "$base_dir" -path "$exclude_dir" -prune -o -exec chown "$owner:$group" {} +
    else
        find "$base_dir" -type d -exec chmod "$dir_mode" {} +
        find "$base_dir" -type f -exec chmod "$file_mode" {} +
        chown -R "$owner:$group" "$base_dir"
    fi
}

set_permissions() {
    log "Setting ownership and permissions..."

    local readonly_dirs=(
        "$APP_CODE_DIR"
        "$API_DIR"
        "$PUBLIC_DIR"
        "$DOCS_DIR"
        "$LOCAL_STFU_DIR"
    )
    local dir
    for dir in "${readonly_dirs[@]}"; do
        set_tree_mode_and_owner "$dir" 0755 0644 root root
    done

    if [[ -d "$TGIF_DIR" ]]; then
        set_tree_mode_and_owner "$TGIF_DIR" 0755 0644 root root "$TGIF_VENV_DIR"
    fi

    local top_level_files=(
        "$APP_DIR/README.md"
        "$APP_DIR/VERSION"
        "$APP_DIR/.gitignore"
        "$APP_DIR/tree.txt"
        "$APP_DIR/screenshot.png"
    )
    local file
    for file in "${top_level_files[@]}"; do
        if [[ -f "$file" ]]; then
            chmod 0644 "$file"
            chown root:root "$file"
        fi
    done

    chmod 0755 "$APP_DIR/setup_alltune2.sh"
    chown root:root "$APP_DIR/setup_alltune2.sh"

    chmod 0755 "$BM_RECEIVE_HELPER"
    chown root:root "$BM_RECEIVE_HELPER"

    chmod 0755 "$LOCAL_STFU_BIN"
    chown root:root "$LOCAL_STFU_BIN"

    chmod 0755 "$TGIF_HELPER"
    chown root:root "$TGIF_HELPER"

    chmod 0755 "$TGIF_SET_TG"
    chown root:root "$TGIF_SET_TG"

    if [[ -d "$TGIF_VENV_DIR" ]]; then
        set_tree_mode_and_owner "$TGIF_VENV_DIR" 0755 0644 root root
        if [[ -d "$TGIF_VENV_DIR/bin" ]]; then
            find "$TGIF_VENV_DIR/bin" -maxdepth 1 -type f -exec chmod 0755 {} +
        fi
    fi

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

    chmod 0640 "$TGIF_MMDVM_HBLINK_INI"
    chown root:"$WEB_GROUP" "$TGIF_MMDVM_HBLINK_INI"

    if [[ -f "$TGIF_MMDVM_HBLINK_INI_EXAMPLE" ]]; then
        chmod 0644 "$TGIF_MMDVM_HBLINK_INI_EXAMPLE"
        chown root:root "$TGIF_MMDVM_HBLINK_INI_EXAMPLE"
    fi

    if [[ -f "$TGIF_MMDVM_PRE_HBLINK_INI" ]]; then
        chmod 0644 "$TGIF_MMDVM_PRE_HBLINK_INI"
        chown root:root "$TGIF_MMDVM_PRE_HBLINK_INI"
    fi
}

install_validated_sudoers_file() {
    local target_file="$1"
    local rule_line="$2"
    local temp_file

    temp_file="$(mktemp)"
    printf '%s\n' "$rule_line" > "$temp_file"
    chmod 0440 "$temp_file"

    visudo -cf "$temp_file" >/dev/null || {
        rm -f "$temp_file"
        fail "visudo validation failed for generated sudoers file: $target_file"
    }

    if [[ -f "$target_file" ]] && cmp -s "$temp_file" "$target_file"; then
        rm -f "$temp_file"
        log "Sudoers file already up to date: $target_file"
        return
    fi

    install -o root -g root -m 0440 "$temp_file" "$target_file"
    rm -f "$temp_file"
    log "Installed sudoers file: $target_file"
}

create_or_update_sudoers_files() {
    log "Ensuring required sudoers rules exist..."

    [[ -x "$ASTERISK_BIN" ]] || fail "Asterisk binary not found at $ASTERISK_BIN"
    [[ -x "$BM_RECEIVE_HELPER" ]] || fail "BM receive helper is not executable: $BM_RECEIVE_HELPER"
    [[ -x "$TGIF_HELPER" ]] || fail "TGIF helper is not executable: $TGIF_HELPER"

    install_validated_sudoers_file "$ASTERISK_SUDOERS_FILE" "$EXPECTED_ASTERISK_SUDOERS_RULE"
    install_validated_sudoers_file "$BM_RECEIVE_SUDOERS_FILE" "$EXPECTED_BM_RECEIVE_SUDOERS_RULE"
    install_validated_sudoers_file "$TGIF_HELPER_SUDOERS_FILE" "$EXPECTED_TGIF_HELPER_SUDOERS_RULE"
}

check_php_syntax() {
    log "Running PHP syntax checks..."

    local php_files=(
        "$APP_DIR/app/Support/Config.php"
        "$APP_DIR/api/connect.php"
        "$APP_DIR/api/status.php"
        "$APP_DIR/api/direct_link.php"
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

    echo "[INFO] TGIF/HBLink reminder: if TGIF does not connect, review the identity/auth fields in hblink.cfg and the related MMDVM/HBLink files."
}

create_or_update_logrotate_files() {
    log "Ensuring BM receive log rotation exists..."

    touch "$BM_RECEIVE_LOG_FILE"
    chmod 0644 "$BM_RECEIVE_LOG_FILE"
    chown root:root "$BM_RECEIVE_LOG_FILE"

    cat > "$BM_RECEIVE_LOGROTATE_FILE" <<EOF
$BM_RECEIVE_LOG_FILE {
    size 1M
    rotate 5
    compress
    delaycompress
    missingok
    notifempty
    copytruncate
    create 0644 root root
}
EOF

    chmod 0644 "$BM_RECEIVE_LOGROTATE_FILE"
    chown root:root "$BM_RECEIVE_LOGROTATE_FILE"

    touch "$STFU_LOG_FILE" "$BM_STFU_LOG_FILE"
    chmod 0644 "$STFU_LOG_FILE" "$BM_STFU_LOG_FILE"
    chown root:root "$STFU_LOG_FILE" "$BM_STFU_LOG_FILE"

    cat > "$STFU_LOGROTATE_FILE" <<EOF
$STFU_LOG_FILE $BM_STFU_LOG_FILE {
    size 1M
    rotate 5
    compress
    delaycompress
    missingok
    notifempty
    copytruncate
    create 0644 root root
}
EOF

    chmod 0644 "$STFU_LOGROTATE_FILE"
    chown root:root "$STFU_LOGROTATE_FILE"

    if command -v logrotate >/dev/null 2>&1; then
        logrotate -d "$BM_RECEIVE_LOGROTATE_FILE" >/dev/null 2>&1 || fail "logrotate validation failed for $BM_RECEIVE_LOGROTATE_FILE"
        logrotate -d "$STFU_LOGROTATE_FILE" >/dev/null 2>&1 || fail "logrotate validation failed for $STFU_LOGROTATE_FILE"
    else
        warn "logrotate command not found. Installed $BM_RECEIVE_LOGROTATE_FILE and $STFU_LOGROTATE_FILE, but rotation cannot run until logrotate is installed."
    fi

    log "Installed BM receive logrotate file: $BM_RECEIVE_LOGROTATE_FILE"
    log "Installed STFU logrotate file: $STFU_LOGROTATE_FILE"
}

create_or_update_apache_security_conf() {
    log "Ensuring Apache security hardening exists..."

    if ! command -v apache2ctl >/dev/null 2>&1; then
        warn "apache2ctl not found. Skipping Apache security config install. Protect $APP_DIR manually before exposing it on a network."
        return
    fi

    if ! command -v a2enconf >/dev/null 2>&1; then
        warn "a2enconf not found. Skipping Apache security config install. Protect $APP_DIR manually before exposing it on a network."
        return
    fi

    mkdir -p /etc/apache2/conf-available

    cat > "$APACHE_SECURITY_CONF_FILE" <<EOF
# AllTune2 security hardening
# Blocks direct web access to local config, runtime, helper, git, log, and data files.
# PHP can still read these files locally from the filesystem.

<Directory "$APP_DIR">
    Options -Indexes

    <FilesMatch "(^\.|^VERSION$|^README\.md$|^tree\.txt$|\.ini(\.example)?$|\.cfg(\.example)?$|\.json$|\.log$|\.bak$|\.pid$|\.state$|\.out$|\.lock$|\.db$|\.sqlite$|\.env$|\.yml$|\.yaml$|\.sh$|\.py$|composer\.(json|lock)$)">
        Require all denied
    </FilesMatch>
</Directory>

<DirectoryMatch "^$APP_DIR/(\.git|app|data|docs|logs|run|stfu|tgif-hblink)(/|$)">
    Require all denied
</DirectoryMatch>
EOF

    chmod 0644 "$APACHE_SECURITY_CONF_FILE"
    chown root:root "$APACHE_SECURITY_CONF_FILE"

    a2enconf "$APACHE_SECURITY_CONF_NAME" >/dev/null || fail "Failed to enable Apache security conf: $APACHE_SECURITY_CONF_NAME"
    apache2ctl configtest >/dev/null || fail "Apache configtest failed after installing $APACHE_SECURITY_CONF_FILE"

    if command -v systemctl >/dev/null 2>&1 && systemctl is-active --quiet apache2; then
        systemctl reload apache2 || fail "Failed to reload apache2 after installing $APACHE_SECURITY_CONF_FILE"
    else
        warn "Apache service is not active or systemctl is unavailable. Installed $APACHE_SECURITY_CONF_FILE, but Apache was not reloaded automatically."
    fi

    log "Installed Apache security conf: $APACHE_SECURITY_CONF_FILE"
}

check_sudoers_requirement() {
    log "Checking installed sudoers files..."

    grep -qF "$EXPECTED_ASTERISK_SUDOERS_RULE" "$ASTERISK_SUDOERS_FILE"         || fail "Expected Asterisk sudoers rule not found in $ASTERISK_SUDOERS_FILE"

    grep -qF "$EXPECTED_BM_RECEIVE_SUDOERS_RULE" "$BM_RECEIVE_SUDOERS_FILE"         || fail "Expected BM receive sudoers rule not found in $BM_RECEIVE_SUDOERS_FILE"

    grep -qF "$EXPECTED_TGIF_HELPER_SUDOERS_RULE" "$TGIF_HELPER_SUDOERS_FILE"         || fail "Expected TGIF helper sudoers rule not found in $TGIF_HELPER_SUDOERS_FILE"

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
    echo "[OK] $APP_NAME setup completed successfully."
    echo
    echo "$APP_NAME setup summary"
    echo "========================================"
    echo "Version:              ${version}"
    echo "Installer mode:       ${INSTALLER_MODE}"
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
    echo "TGIF MMDVM example:   $TGIF_MMDVM_HBLINK_INI_EXAMPLE"
    echo "Web user/group:       $WEB_USER:$WEB_GROUP"
    echo "Asterisk sudoers:     $ASTERISK_SUDOERS_FILE"
    echo "BM helper sudoers:    $BM_RECEIVE_SUDOERS_FILE"
    echo "TGIF helper sudoers:  $TGIF_HELPER_SUDOERS_FILE"
    echo "BM receive log:       $BM_RECEIVE_LOG_FILE"
    echo "BM logrotate:         $BM_RECEIVE_LOGROTATE_FILE"
    echo "STFU logs:            $STFU_LOG_FILE, $BM_STFU_LOG_FILE"
    echo "STFU logrotate:       $STFU_LOGROTATE_FILE"
    echo "Apache security conf: $APACHE_SECURITY_CONF_FILE"
    echo

    echo "Notes:"
    echo "- Existing config.ini, favorites.txt, hblink.cfg, and MMDVM_Bridge.pre-hblink.ini are preserved."
    echo "- Apache security hardening blocks direct browser access to config, git, data, logs, run, STFU, and TGIF/HBLink runtime files."
    echo "- If MMDVM_Bridge.hblink.ini is missing, setup creates it from the repo example file."
    echo "- BM is one-step and uses the AllTune2-local BM receive helper."
    echo "- TGIF uses the AllTune2-local HBLink helper and Python venv."
    echo "- TGIF Python packages are only reinstalled when the venv is new, broken, missing packages, or requirements.txt changes."
    echo "- The installer does not overwrite /opt/MMDVM_Bridge/MMDVM_Bridge.ini, /opt/MMDVM_Bridge/DVSwitch.ini, or /opt/Analog_Bridge/Analog_Bridge.ini."
    echo "- TGIF/HBLink often needs both a base DMR ID and a hotspot/repeater-style suffixed radio ID in the HBLink/MMDVM config path."
    echo "- TGIF/HBLink troubleshooting: if TGIF does not connect, review hblink.cfg and the related MMDVM/HBLink identity values."
    echo

    echo "Next steps:"
    echo "1. Open /alltune2/public/ in the browser."
    echo "2. Test BM, TGIF, YSF, AllStarLink, EchoLink, Disconnect DVSwitch, and Disconnect All."
    echo "3. For new installs only: edit $CONFIG_FILE and $TGIF_HBLINK_CFG if real values have not been set yet."
    echo "4. For TGIF/HBLink troubleshooting only: review $TGIF_MMDVM_HBLINK_INI and these external DVSwitch files:"
    echo "   - $DVSWITCH_INI"
    echo "   - $MMDVM_BRIDGE_INI"
    echo "   - $ANALOG_BRIDGE_INI"
    echo
}

main() {
    require_root
    require_app_dir
    validate_installer_mode

    step "Checking runtime prerequisites..."
    check_runtime_tools
    check_web_user

    step "Preparing application files..."
    make_dirs
    create_config_example
    create_config_if_missing
    create_favorites_if_missing
    create_tgif_hblink_cfg_example
    create_tgif_hblink_cfg_if_missing
    create_tgif_mmdvm_hblink_ini_if_missing

    step "Checking repo and system dependencies..."
    check_required_repo_files
    check_optional_files
    check_dvswitch_dependencies
    check_helper_local_paths
    ensure_tgif_runtime_local_files
    validate_tgif_alias_json_files

    step "Checking TGIF/HBLink Python environment..."
    build_tgif_venv

    step "Applying permissions and sudoers..."
    set_permissions
    create_or_update_sudoers_files
    create_or_update_logrotate_files
    create_or_update_apache_security_conf

    step "Running installer self-checks..."
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
