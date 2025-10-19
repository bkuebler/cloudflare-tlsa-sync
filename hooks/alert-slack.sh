#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Cloudflare TLSA Sync - Alert Hook: Slack
#
# (C) 2025 Benjamin Kübler <b.kuebler@kuebler-it.de>
#
# Source: https://github.com/bkuebler/cloudflare-tlsa-sync
# Maintainer: Benjamin Kübler <b.kuebler@kuebler-it.de>
# Contributors: see CONTRIBUTING.md or Git log
#
# License: GPLv3 or later
# -----------------------------------------------------------------------------
# usage: ./alert-slack.sh <caller> <err_type> <domain_or_rname> <details>
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK"
MESSAGE="[$(date '+%FT%T')] ALERT from $1: $2 $3 ($4)"
curl -X POST -H 'Content-type: application/json' \
  --data "{\"text\":\"${MESSAGE}\"}" \
  "$SLACK_WEBHOOK_URL"
