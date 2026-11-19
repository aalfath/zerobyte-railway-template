# Zerobyte (https://zerobyte.app), official image pinned by version and digest.
# The digest is the multi-arch index of ghcr.io/nicotsx/zerobyte:v0.44.2.
FROM ghcr.io/nicotsx/zerobyte:v0.44.2@sha256:e100152258f0d167778e0623985a3ea0d1d98e5749d3e316911da8b13c48e3d2

COPY railway-start.sh /usr/local/bin/railway-start.sh
RUN chmod 755 /usr/local/bin/railway-start.sh

# The image's ENTRYPOINT (tini) stays; only the command is wrapped.
CMD ["/usr/local/bin/railway-start.sh"]
