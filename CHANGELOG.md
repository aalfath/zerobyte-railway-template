# Changelog

## v0.44.2 (2026-11-19)

First release of the Railway template.

- Zerobyte v0.44.2, official image `ghcr.io/nicotsx/zerobyte:v0.44.2@sha256:e100152258f0d167778e0623985a3ea0d1d98e5749d3e316911da8b13c48e3d2` (restic 0.19.1, rclone 1.75.2, Shoutrrr 0.23.0).
- One volume at `/var/lib/zerobyte`; health check on `/api/healthcheck`.
- `railway-start.sh` sets `TRUST_PROXY=true`, `ENABLE_REMOTE_AGENTS=true`, `RESTIC_HOSTNAME=zerobyte` and keeps `rclone.conf` on the volume.
