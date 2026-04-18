#!/bin/bash
set -euo pipefail

TG="${1:-}"
RULES_DIR="${2:-/var/www/html/alltune2/tgif-hblink}"
TEMPLATE="${RULES_DIR}/rules.py.template"
RULES="${RULES_DIR}/rules.py"
ANALOG_INI="${ANALOG_INI:-/opt/Analog_Bridge/Analog_Bridge.ini}"

read_ini_value() {
    local key="$1"
    local file="$2"
    [[ -f "$file" ]] || return 0
    awk -F= -v k="$key" '
        $1 ~ "^[[:space:]]*" k "[[:space:]]*$" {
            v=$2
            sub(/;.*/, "", v)
            gsub(/\r/, "", v)
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", v)
            print v
            exit
        }
    ' "$file" 2>/dev/null
}

read_local_tg() {
    local tg
    tg="$(read_ini_value "gatewayDmrId" "$ANALOG_INI")"
    if [[ ! "$tg" =~ ^[0-9]+$ ]]; then
        tg="$(read_ini_value "txTg" "$ANALOG_INI")"
    fi
    printf '%s' "$tg"
}

[[ -n "$TG" ]] || { echo "Usage: $0 <talkgroup> [rules_dir]" >&2; exit 1; }
[[ "$TG" =~ ^[0-9]+$ ]] || { echo "Talkgroup must be numeric" >&2; exit 1; }
[[ -f "$TEMPLATE" ]] || { echo "Missing template: $TEMPLATE" >&2; exit 1; }

LOCAL_TG="$(read_local_tg)"
[[ "$LOCAL_TG" =~ ^[0-9]+$ ]] || {
    echo "Failed to determine local TG from $ANALOG_INI" >&2
    exit 1
}

sed \
    -e "s/__LOCAL_TG__/${LOCAL_TG}/g" \
    -e "s/__TG__/${TG}/g" \
    "$TEMPLATE" > "$RULES"

echo "Wrote $RULES for upstream TG ${TG} and local TG ${LOCAL_TG}"