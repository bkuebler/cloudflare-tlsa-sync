#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Cloudflare TLSA Sync - Alert Hook: Icinga2 API
#
# (C) 2025 Benjamin Kübler <b.kuebler@kuebler-it.de>
#
# Source: https://github.com/bkuebler/cloudflare-tlsa-sync
# Maintainer: Benjamin Kübler <b.kuebler@kuebler-it.de>
# Contributors: see CONTRIBUTING.md or Git log
#
# License: GPLv3 or later
# -----------------------------------------------------------------------------
# usage: ./alert-icinga2api.sh <caller> <err_type> <domain_or_rname> <details>
# requires: curl

ICINGA_API_HOST="https://your.icinga.host:5665"
ICINGA_API_USER="apiuser"
ICINGA_API_PASS="apipassword"

ICINGA_HOST="dns-system"           # adjust hostname to your Icinga2 configuration
ICINGA_SERVICE="cloudflare-tlsa"   # adjust service name (must be a passive check command or similar)

STATE=2         # 0=OK, 1=Warning, 2=Critical
MSG="TLSA Sync ERROR [$2 $3]: $4"

# Compose JSON payload
PAYLOAD=$(cat <<EOF
{
  "type": "Service",
  "filter": "host.name==\"$ICINGA_HOST\" && service.name==\"$ICINGA_SERVICE\"",
  "exit_status": $STATE,
  "plugin_output": "$MSG"
}
EOF
)

# REST API call
curl -su "$ICINGA_API_USER:$ICINGA_API_PASS" -k -s \
    -H 'Accept: application/json' -H 'Content-Type: application/json' \
    -X POST "$ICINGA_API_HOST/v1/actions/process-check-result" \
    -d "$PAYLOAD" > /dev/null
