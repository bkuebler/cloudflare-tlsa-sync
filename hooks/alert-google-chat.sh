#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Cloudflare TLSA Sync - Alert Hook: Google Chat
#
# (C) 2025 Benjamin Kübler <b.kuebler@kuebler-it.de>
#
# Source: https://github.com/bkuebler/cloudflare-tlsa-sync
# Maintainer: Benjamin Kübler <b.kuebler@kuebler-it.de>
# Contributors: see CONTRIBUTING.md or Git log
#
# License: GPLv3 or later
# -----------------------------------------------------------------------------

# usage: ./alert-google-chat.sh <caller> <err_type> <domain_or_rname> <details>

GC_WEBHOOK_URL="https://chat.googleapis.com/v1/spaces/.../messages?key=...&token=..."

MSG="⚠️ *TLSA-Error* ($2 $3): $4"

curl -s -X POST \
    -H "Content-Type: application/json; charset=UTF-8" \
    -d "{\"text\": \"$MSG\"}" "$GC_WEBHOOK_URL" > /dev/null
