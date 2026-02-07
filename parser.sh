#!/usr/bin/env bash

set -euo pipefail

INPUT=""
SORT_FIELD=""
FILTER_STATUS=""
DO_GIT=false

usage() {
    echo "Usage: $0 --input file.log [--sort ip|time|status] [--filter-status N] [--git]"
    exit 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --input) INPUT="$2"; shift 2;;
        --sort) SORT_FIELD="$2"; shift 2;;
        --filter-status) FILTER_STATUS="$2"; shift 2;;
        --git) DO_GIT=true; shift;;
        *) usage;;
    esac
done

[[ -z "$INPUT" ]] && usage
[[ ! -f "$INPUT" ]] && { echo "Input file not found: $INPUT"; exit 1; }

TODAY=$(date +"%Y-%m-%d")
OUTPUT="parsed_${TODAY}.csv"

TMP=$(mktemp)

awk '
{
    if (match($0, /^([^ ]+) - ([^ ]+) \[([^]]+)\] "([A-Z]+) ([^ ]+) ([^"]+)" ([0-9]+) ([0-9-]+)/, a)) {
        print a[1] "," a[2] "," a[3] "," a[4] "," a[5] "," a[6] "," a[7] "," a[8]
    }
}
' "$INPUT" > "$TMP"

if [[ -n "$FILTER_STATUS" ]]; then
    grep ",$FILTER_STATUS$" "$TMP" > "${TMP}_f" || true
    mv "${TMP}_f" "$TMP"
fi

case "$SORT_FIELD" in
    ip) sort -t, -k1,1 "$TMP" -o "$TMP";;
    time) sort -t, -k3,3 "$TMP" -o "$TMP";;
    status) sort -t, -k7,7n "$TMP" -o "$TMP";;
esac

echo "ip,user,time,method,url,protocol,status,size" > "$OUTPUT"
cat "$TMP" >> "$OUTPUT"

rm "$TMP"

if $DO_GIT; then
    git add "$OUTPUT"
    git commit -m "Add parsed CSV: $OUTPUT"
    git push
fi

echo "CSV saved to $OUTPUT"
