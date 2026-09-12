# Authelia on Pasiv Black Box

Authelia provides authentication for selected Pasiv Black Box applications. The validated deployment is independent from any Authelia instance on the primary home server so the monitoring plane remains usable when the main server is unavailable.

## Tested image

`docker.io/authelia/authelia:latest`

Validated version: 4.39.22.

## Local paths

```text
/etc/pasiv-black-box/authelia/authelia.env
/etc/pasiv-black-box/authelia/config/
/etc/pasiv-black-box/authelia/secrets/
/var/mnt/monitoring/authelia/
```

Keep secret files root-owned and out of Git. The tested configuration uses Authelia `_FILE` environment variables. When a secret is supplied by `_FILE`, do not define that same secret again in `configuration.yml`.

## Network model

Authelia joins `pasiv-monitoring` as alias `authelia` and also publishes `127.0.0.1:9091` for local host testing. Caddy can reach it internally as `authelia:9091`.

For forward-auth protected services, use the Authelia Caddy integration and test redirects with sanitized deployment domains such as `auth-bbox.example.com`.

Grafana was validated differently: Grafana uses Authelia as its OIDC provider, so Caddy does not need a second forward-auth layer in front of Grafana.

## Deploy

Create the local configuration, secret, and persistent-data directories, then copy the supplied Quadlet:

```bash
sudo cp \
  /usr/share/pasiv-black-box/quadlets/authelia/authelia.container \
  /etc/containers/systemd/authelia.container
sudo systemctl daemon-reload
sudo systemctl start authelia.service
```

Validate the journal, `127.0.0.1:9091`, Caddy integration, authentication flow, and reboot persistence before relying on it for access control.
