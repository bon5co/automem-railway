#!/bin/sh
set -e

if [ -z "${FALKOR_PASSWORD}" ]; then
  echo "FATAL: FALKOR_PASSWORD is empty; the memory graph would accept" >&2
  echo "       unauthenticated commands from anything on the project network." >&2
  exit 1
fi

DATA_PATH="${FALKORDB_DATA_PATH:-/var/lib/falkordb/data}"
mkdir -p "$DATA_PATH"

REDIS_ARGS="${REDIS_ARGS:---save 60 1 --appendonly yes --appendfsync everysec} --requirepass ${FALKOR_PASSWORD}"
export REDIS_ARGS
export FALKORDB_DATA_PATH="$DATA_PATH"

echo "[railway] falkordb: authentication enabled, browser disabled, data=${DATA_PATH}"
exec /var/lib/falkordb/bin/run.sh
