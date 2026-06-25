#!/bin/sh
#───────────────────────────────────────────────────────────────────────────────
# check-upstream.sh  —  Find the latest date-tagged Odoo release for a given
#                       major.minor version (e.g. 18.0).
#
# Usage:  ./check-upstream.sh <ODOO_VERSION>
# Example:
#     ./check-upstream.sh 18.0
#     →  18.0-20260619
#───────────────────────────────────────────────────────────────────────────────
set -eu

ODOO_VERSION="${1:?Usage: $0 <ODOO_VERSION>}"

# Docker Hub API — fetch tags for the odoo library image
# We paginate through enough pages to reliably find the newest date tag.
PAGE=1
RESULTS=""
while true; do
  RESP=$(curl -sS "https://hub.docker.com/v2/repositories/library/odoo/tags?page=${PAGE}&page_size=100")
  COUNT=$(echo "$RESP" | tr -d '\n' | grep -o '"name"' | wc -l)
  [ "$COUNT" -eq 0 ] && break

  RESULTS="${RESULTS}${RESULTS:+ }$(echo "$RESP" | tr -d '\n')"
  NEXT=$(echo "$RESP" | tr -d '\n' | sed 's/.*"next":"//;s/".*//')
  [ -z "$NEXT" ] || [ "$NEXT" = "null" ] && break
  PAGE=$((PAGE + 1))
done

# Extract date-based tags for the specified major.minor version
# Pattern:  <major>.<minor>-YYYYMMDD
LATEST=$(echo "$RESULTS" | tr '}' '\n' | \
  grep -o "\"name\":\"${ODOO_VERSION}-[0-9]*\"" | \
  sed 's/"name":"//;s/"//' | \
  sort -r | head -1)

if [ -z "$LATEST" ]; then
  echo "ERROR: no date-tagged images found for Odoo ${ODOO_VERSION}" >&2
  exit 1
fi

echo "$LATEST"
