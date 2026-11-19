[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/zerobyte?utm_medium=integration&utm_source=button&utm_campaign=zerobyte)

# Zerobyte on Railway

A one-click [Railway](https://railway.com) template for [Zerobyte](https://zerobyte.app), a web UI that schedules, runs and monitors encrypted [restic](https://restic.net) backups, with retention policies, restores and notifications.

## What it deploys

- **Zerobyte v0.44.2**, from the official image `ghcr.io/nicotsx/zerobyte:v0.44.2`, pinned by digest (`sha256:e100152258f0d167778e0623985a3ea0d1d98e5749d3e316911da8b13c48e3d2`) in the [`Dockerfile`](Dockerfile). The image bundles restic 0.19.1, rclone 1.75.2 and Shoutrrr 0.23.0.
- One service with a public HTTPS domain on port 4096 and a health check on `/api/healthcheck`.
- One volume at `/var/lib/zerobyte`. It holds the SQLite database, the restic password, the restic cache, local repositories and `rclone.conf`, so everything survives redeploys and restarts.

The wrapper is small: [`railway-start.sh`](railway-start.sh) fills in defaults for running behind Railway's HTTPS proxy, creates the data folders on a fresh volume, then starts the stock server.

## Variables

| Variable | Default | What it does |
|---|---|---|
| `APP_SECRET` | generated (64 hex characters) | Encrypts the credentials Zerobyte stores in its database. Keep it: if it changes, stored credentials can't be decrypted. |
| `BASE_URL` | `https://${{RAILWAY_PUBLIC_DOMAIN}}` | Public URL. Login cookies and auth checks use it. Set it to `https://YOUR-DOMAIN` if you add a custom domain. |
| `TZ` | `UTC` | Time zone for backup schedules, for example `Europe/Berlin`. |
| `PORT` | `4096` | Port Zerobyte listens on; the Railway domain points at it. |

Set in `railway-start.sh` and overridable with a service variable: `TRUST_PROXY=true` (Railway's proxy is the only way in), `ENABLE_REMOTE_AGENTS=true`, `RESTIC_HOSTNAME=zerobyte` (a stable snapshot hostname across redeploys) and `RCLONE_CONFIG_DIR=/var/lib/zerobyte/rclone`. Every other option (`TRUSTED_ORIGINS`, `WEBHOOK_ALLOWED_ORIGINS`, `GOMAXPROCS`, `LOG_LEVEL`, provisioning) is optional; see Zerobyte's [configuration reference](https://zerobyte.app/docs/configuration).

## After deploying

1. Open your Railway URL straight away. The first visitor creates the admin account, so do it before you share the link.
2. Download the recovery key when Zerobyte asks for it and keep it somewhere safe. It holds the restic password; without it and the server, your backups can't be read.
3. Add a **repository** (where backups go): S3-compatible storage (AWS S3, Backblaze B2, Cloudflare R2, Wasabi, a Railway bucket), Google Cloud Storage, Azure, SFTP, a restic REST server, or rclone remotes (put `rclone.conf` in `/var/lib/zerobyte/rclone`).
4. Add a **source** (what to back up) and a backup schedule.

### What you can back up from Railway

Railway containers don't get `CAP_SYS_ADMIN` or `/dev/fuse`, so Zerobyte can't mount NFS, SMB, WebDAV, SFTP or rclone shares as sources here. Two things work:

- **Remote agents** (enabled by this template): in **Settings → Machines → Connect machine**, Zerobyte gives you a one-time command or a Docker Compose snippet for `ghcr.io/nicotsx/zerobyte-agent`. The agent runs on the machine you want to back up, connects out to your Railway URL over a WebSocket (no inbound port), and sends restic backups straight to your repository. Use the agent version that matches the server (v0.44.2). Upstream still marks remote agents as new; local and rclone repositories aren't available for agent sources.
- **Directory** sources inside the container, for example `/var/lib/zerobyte` itself.

Restores run on the Zerobyte server: restore to a folder there or download the files.

## Updates

This template builds from this repository. When a new Zerobyte release comes out, we bump the pinned tag and digest in the `Dockerfile` and note it in [`CHANGELOG.md`](CHANGELOG.md). Railway then shows an "update available" notice on your project, and you choose when to apply it. Your data stays on the volume. Zerobyte is still 0.x and its releases can change things, so read the changelog first: breaking changes are listed at the top of each entry.

## Licence

Zerobyte is AGPL-3.0, by Nicolas Meienberger and contributors at [nicotsx/zerobyte](https://github.com/nicotsx/zerobyte). restic is BSD-2-Clause. This repository only holds the Railway packaging.
