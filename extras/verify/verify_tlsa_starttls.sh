#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Cloudflare TLSA Sync - Verify TLSA with STARTTLS
#
# (C) 2025 Benjamin Kübler <b.kuebler@kuebler-it.de>
#
# Source: https://github.com/bkuebler/cloudflare-tlsa-sync
# Maintainer: Benjamin Kübler <b.kuebler@kuebler-it.de>
# Contributors: see CONTRIBUTING.md or Git log
#
# License: GPLv3 or later
# -----------------------------------------------------------------------------
SCRIPT_NAME="$(basename "$0")"
OPENSSL_CONNECT_PARAMS=""

function show_help() {
    cat <<EOF
Usage: $SCRIPT_NAME [-s STARTTLS_TYPE] [-h] FQDN PORT TLSA_RECORD

Options:
  -s STARTTLS_TYPE      set STARTTLS type; possible values are: smtp, pop3,
                        imap, ftp, xmpp, xmpp-server, telnet, irc, mysql,
                        postgres, lmtp, nntp, sieve, ldap
  -h                    show this help.

Examples:
  $SCRIPT_NAME
  $SCRIPT_NAME -s smtp mail.example.com 25 "3 1 1 254129c7xxx205ld......39462e"
EOF
}

while getopts "s:h" opt; do
    case $opt in
        s)
            OPENSSL_CONNECT_PARAMS=("-starttls" "$OPTARG")
            ;;
        h)
            show_help
            exit 0
            ;;
        \?)
            echo "Unknown argument: -$OPTARG" >&2
            show_help
            exit 1
            ;;
    esac
done

shift $((OPTIND -1))

if [[ $# -ne 3 ]]; then
    echo "FQDN, PORT and TLSA_RECORD are required arguments!"
    show_help
    exit 1
fi
HOST="$1"
PORT="$2"
RECORD_CONTENT="$3"

openssl s_client -brief "${OPENSSL_CONNECT_PARAMS[@]}" -dane_tlsa_domain \
    "$HOST" -dane_tlsa_rrdata "$RECORD_CONTENT" -connect "$HOST:$PORT" <<< "Q"

exit 0
