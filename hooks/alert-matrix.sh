#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Cloudflare TLSA Sync - Alert Hook: Matrix
#
# (C) 2025 Benjamin Kübler <b.kuebler@kuebler-it.de>
#
# Source: https://github.com/bkuebler/cloudflare-tlsa-sync
# Maintainer: Benjamin Kübler <b.kuebler@kuebler-it.de>
# Contributors: see CONTRIBUTING.md or Git log
#
# License: GPLv3 or later
# -----------------------------------------------------------------------------
# usage: ./alert-matrix.sh <caller> <err_type> <domain_or_rname> <details>
# requires: curl, jq

MATRIX_HOMESERVER="https://matrix.example.com"
MATRIX_ACCESS_TOKEN="YOUR_ACCESS_TOKEN"
MATRIX_ROOMID="!abcdefg:example.com"

MSG="🚨 TLSA Sync Error ($2 $3): $4"

curl -s -XPOST "${MATRIX_HOMESERVER}/_matrix/client/r0/rooms/${MATRIX_ROOMID}/send/m.room.message?access_token=${MATRIX_ACCESS_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "{\"msgtype\":\"m.text\",\"body\":\"$MSG\"}" > /dev/null
