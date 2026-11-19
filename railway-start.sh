#!/bin/sh
# Railway wrapper for Zerobyte: fills in defaults that suit Railway, then starts the stock server.
set -e

# Public URL: the template sets BASE_URL=https://${{RAILWAY_PUBLIC_DOMAIN}}; fall back to it if empty.
if [ -z "${BASE_URL:-}" ] && [ -n "${RAILWAY_PUBLIC_DOMAIN:-}" ]; then
  export BASE_URL="https://${RAILWAY_PUBLIC_DOMAIN}"
fi

# Railway's edge proxy terminates TLS and is the only way in, so trust its X-Forwarded-* headers.
export TRUST_PROXY="${TRUST_PROXY:-true}"
# Remote agents connect to this server over a WebSocket; they back up the machines Zerobyte can't mount on Railway.
export ENABLE_REMOTE_AGENTS="${ENABLE_REMOTE_AGENTS:-true}"
# Keep restic's snapshot hostname stable across redeploys (Railway's container hostname changes).
export RESTIC_HOSTNAME="${RESTIC_HOSTNAME:-zerobyte}"
export TZ="${TZ:-UTC}"
export PORT="${PORT:-4096}"

# All state (SQLite database, restic password, cache, local repositories) lives on the volume.
mkdir -p /var/lib/zerobyte/data /var/lib/zerobyte/repositories /var/lib/zerobyte/restic/cache
# rclone remotes: keep rclone.conf on the volume too, so it survives redeploys.
export RCLONE_CONFIG_DIR="${RCLONE_CONFIG_DIR:-/var/lib/zerobyte/rclone}"
mkdir -p "$RCLONE_CONFIG_DIR"

cd /app
exec bun .output/server/index.mjs
