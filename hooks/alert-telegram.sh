#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Cloudflare TLSA Sync - Alert Hook: Telegram
#
# (C) 2025 Benjamin Kübler <b.kuebler@kuebler-it.de>
#
# Source: https://github.com/bkuebler/cloudflare-tlsa-sync
# Maintainer: Benjamin Kübler <b.kuebler@kuebler-it.de>
# Contributors: see CONTRIBUTING.md or Git log
#
# License: GPLv3 or later
# -----------------------------------------------------------------------------
# usage: ./alert-telegram.sh <caller> <err_type> <domain_or_rname> <details>
BOT_TOKEN="YOUR:BOT_TOKEN"
CHAT_ID="123456789" # your own chat ID

MSG="[$(date '+%FT%T')] TLSA Sync Error ($2 $3): $4"

curl -s --data "chat_id=${CHAT_ID}&text=$(echo "$MSG" | sed 's/"/\\"/g')" \
    "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" > /dev/null
