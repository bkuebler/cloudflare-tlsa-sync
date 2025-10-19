#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Cloudflare TLSA Sync
#
# (C) 2025 Benjamin Kübler <b.kuebler@kuebler-it.de>
#
# Source: https://github.com/bkuebler/cloudflare-tlsa-sync
# Maintainer: Benjamin Kübler <b.kuebler@kuebler-it.de>
# Contributors: see CONTRIBUTING.md or Git log
#
# License: GPLv3 or later
# -----------------------------------------------------------------------------

# hard fail on errors
set -e

SCRIPT_VERSION="1.0.0"
SCRIPT_NAME="$(basename "$0")"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEFAULT_CONFIG="$SCRIPT_DIR/cloudflare_tlsa_sync.json"
CONFIG=""
DRY_RUN="no"

function show_help() {
    cat <<EOF
$SCRIPT_NAME - Cloudflare TLSA Sync ($SCRIPT_VERSION)

Usage: $SCRIPT_NAME [-c CONFIG] [-h]

Options:
  -t             test mode (no changes applied), tells what would be done.
  -c CONFIG      set JSON-Config file; otherwise "cloudflare_tlsa_sync.json" in the script directory is used.
  -h             show this help.

Examples:
  $SCRIPT_NAME
  $SCRIPT_NAME -c /etc/cloudflare/cloudflare_tlsa_sync.json
EOF
}

while getopts ":t:c:h" opt; do
    case $opt in
        c)
            CONFIG="$OPTARG"
            ;;
        h)
            show_help
            exit 0
            ;;
        t)
            DRY_RUN=yes
            ;;
        \?)
            echo "Unknown argument: -$OPTARG" >&2
            show_help
            exit 1
            ;;
    esac
done

shift $((OPTIND -1))

# IF no config explicitly set, use the one in the script directory
if [[ -z "$CONFIG" ]]; then
    CONFIG="$DEFAULT_CONFIG"
fi

# check if config file exists otherwise exit
if [[ ! -f "$CONFIG" ]]; then
    echo "Configuration $CONFIG not found!"
    show_help
    exit 1
fi

if [[ ! -d "$(dirname "$CONFIG")/hooks" ]]; then
    log "Hooks will be searched in $SCRIPT_DIR/hooks"
    HOOKS_DIR="$SCRIPT_DIR/hooks"
else
    HOOKS_DIR="$(dirname "$CONFIG")/hooks"
fi

JQ=$(command -v jq)
CURL=$(command -v curl)
OPENSSL=$(command -v openssl)
XXD=$(command -v xxd)

# check dependencies
for cmd in "$JQ" "$CURL" "$OPENSSL" "$XXD"; do
    if [[ -z "$cmd" ]]; then
        echo "Required command not found: $cmd"
        exit 1
    fi
done

function log() {
    if command -v systemd-cat > /dev/null; then
        echo "$1" | systemd-cat -t cloudflare-tlsa-sync -p info
    else
        echo "$(date '+%FT%T') $1"
    fi
}
function log_error() {
    if command -v systemd-cat > /dev/null; then
        echo "$1" | systemd-cat -t cloudflare-tlsa-sync -p err
    else
        echo "$(date '+%FT%T') [ERROR] $1"
    fi
}

# alert hooks call (multiple hooks possible)
function alert_hooks() {
    local type="$1"
    local domain="$2"
    local detail="$3"
    local HOOKS_N
    HOOKS_N=$(jq '.alert_hooks | length' "$CONFIG" 2>/dev/null)
    if [[ "$HOOKS_N" =~ ^[0-9]+$ ]] && [ "$HOOKS_N" -gt 0 ]; then
        for ((i=0; i<HOOKS_N; ++i)); do
            local hook
            hook=$(jq -r ".alert_hooks[$i]" "$CONFIG")
            if [[ -x "$HOOKS_DIR/$hook" ]]; then
                "$HOOKS_DIR/$hook" "$SCRIPT_NAME" "$type" "$domain" "$detail" &
            else
                log_error "Alert-Hook $hook is not executable! Chmod +x to fix."
            fi
        done
    fi
}

CF_API_TOKEN=$(jq -r '.cf_api_token' "$CONFIG")
CF_API_BASE="https://api.cloudflare.com/client/v4"

log "Script $SCRIPT_NAME started, config $CONFIG"

DOMAINS_N=$(jq '.domains | length' "$CONFIG")
for ((d=0; d<DOMAINS_N; ++d)); do
    DOMAIN=$(jq -r ".domains[$d].domain" "$CONFIG")
    log "Processing domain $DOMAIN"

    # Zone-ID holen
    ZONE_ID=$($CURL -s -X GET "$CF_API_BASE/zones?name=$DOMAIN" \
        -H "Authorization: Bearer $CF_API_TOKEN" \
        -H "Content-Type: application/json" | $JQ -r '.result[0].id')
    if [[ -z "$ZONE_ID" || "$ZONE_ID" == "null" ]]; then
        MSG="Zone ID for $DOMAIN not found!"
        log_error "$MSG"
        alert_hooks "ZONEID_FAIL" "$DOMAIN" "$MSG"
        continue
    fi

    RECORDS_N=$(jq ".domains[$d].records | length" "$CONFIG")
    for ((r=0; r<RECORDS_N; ++r)); do
        HOST=$(jq -r ".domains[$d].records[$r].host" "$CONFIG")
        CERTFILE=$(jq -r ".domains[$d].records[$r].certificate_file" "$CONFIG")
        if [[ ! -f "$CERTFILE" ]]; then
            MSG="Certificate $CERTFILE not found for $HOST.$DOMAIN"
            log_error "$MSG"
            alert_hooks "CERT_FAIL" "$DOMAIN" "$MSG"
            continue
        fi
        PORTS=$(jq ".domains[$d].records[$r].ports[]" "$CONFIG")
        TTL=$(jq -r ".domains[$d].records[$r].ttl" "$CONFIG")
        if [[ -z "$TTL" || "$TTL" == "null" ]]; then
            log "TTL for $HOST.$DOMAIN not found, using default 3600"
            TTL=3600
        fi
        for PORT in $PORTS; do
            RECORD_NAME="_${PORT}._tcp.$HOST.$DOMAIN"
            # TLSA-Hash calculate ("3 1 1")
            RECORD_HASH=$($OPENSSL x509 -in "$CERTFILE" -outform DER | $OPENSSL dgst -sha256 -binary | $XXD -p -c 256)
            RECORD_CONTENT="3 1 1 $RECORD_HASH"
            log "TLSA for $RECORD_NAME: $RECORD_CONTENT"

            # Check if record exists
            RECORD_ID=$($CURL -s -X GET "$CF_API_BASE/zones/$ZONE_ID/dns_records?type=TLSA&name=$RECORD_NAME" \
              -H "Authorization: Bearer $CF_API_TOKEN" \
              -H "Content-Type: application/json" | $JQ -r '.result[0].id')

            POST_DATA="{\"type\": \"TLSA\", \"name\": \"$RECORD_NAME\", \"content\": \"$RECORD_CONTENT\", \"ttl\": $TTL, \"proxied\": false}"

            if [[ "$RECORD_ID" != "null" && "$RECORD_ID" != "" ]]; then
                # TODOFIX: Check if content is the same, then skip
                log "Update existing record ($RECORD_ID) for $RECORD_NAME"
                if [[ "$DRY_RUN" == "yes" ]]; then
                    log "[DRY-RUN] Would update record $RECORD_NAME with content: $RECORD_CONTENT"
                    continue
                fi
                RESULT=$($CURL -s -X PUT "$CF_API_BASE/zones/$ZONE_ID/dns_records/$RECORD_ID" \
                    -H "Authorization: Bearer $CF_API_TOKEN" \
                    -H "Content-Type: application/json" \
                    --data "$POST_DATA")
            else
                log "Creating new record for $RECORD_NAME"
                if [[ "$DRY_RUN" == "yes" ]]; then
                    log "[DRY-RUN] Would create record $RECORD_NAME with content: $RECORD_CONTENT"
                    continue
                fi
                RESULT=$($CURL -s -X POST "$CF_API_BASE/zones/$ZONE_ID/dns_records" \
                    -H "Authorization: Bearer $CF_API_TOKEN" \
                    -H "Content-Type: application/json" \
                    --data "$POST_DATA")
            fi

            SUCCESS=$(echo "$RESULT" | jq -r '.success')
            if [[ "$SUCCESS" == "true" ]]; then
                log "TLSA $RECORD_NAME successfully created/updated."
            else
                ERRMSG=$(echo "$RESULT" | jq -r '.errors | tostring')
                log_error "Error with $RECORD_NAME: $ERRMSG"
                alert_hooks "API_FAIL" "$RECORD_NAME" "$ERRMSG"
            fi
        done
    done
done

log "Script $SCRIPT_NAME completed."
