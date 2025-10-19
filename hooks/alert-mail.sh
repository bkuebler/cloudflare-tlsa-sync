#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Cloudflare TLSA Sync - Alert Hook: Mail
#
# (C) 2025 Benjamin Kübler <b.kuebler@kuebler-it.de>
#
# Source: https://github.com/bkuebler/cloudflare-tlsa-sync
# Maintainer: Benjamin Kübler <b.kuebler@kuebler-it.de>
# Contributors: see CONTRIBUTING.md or Git log
#
# License: GPLv3 or later
# -----------------------------------------------------------------------------
# usage: ./alert-mail.sh <caller> <err_type> <domain_or_rname> <details>
echo "
[$(date '+%FT%T')] ALERT from $1: $2 $3 ($4)
" | mail -s "TLSA Sync Error ($2 $3)" admin@example.com
