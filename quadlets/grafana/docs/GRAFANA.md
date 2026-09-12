# Grafana on Pasiv Black Box

Grafana is the human-facing dashboard and query UI for Pasiv Black Box observability data.

## Tested image

`docker.io/grafana/grafana:latest`

The validated deployment stores persistent state under `/var/mnt/monitoring/grafana` and runs with UID/GID 472.

## Local paths

```text
/etc/pasiv-black-box/grafana/grafana.env
/var/mnt/monitoring/grafana/
```

Create persistent storage with the container ownership expected by Grafana and apply `container_file_t` using the appliance's `/var/mnt -> /mnt` SELinux equivalency.

## Network and access

Grafana joins `pasiv-monitoring` with alias `grafana` and does not publish a host port in the supplied template. Caddy reaches it internally as `grafana:3000`.

The tested authentication model uses Authelia as Grafana's OpenID Connect provider. Grafana establishes its own authenticated session after the OIDC login, so this is intentionally different from placing Caddy `forward_auth` in front of every request.

Keep OIDC client secrets in `/etc/pasiv-black-box/grafana/grafana.env`, never in the public Quadlet template.

## Deploy

```bash
sudo cp \
  /usr/share/pasiv-black-box/quadlets/grafana/grafana.container \
  /etc/containers/systemd/grafana.container
sudo systemctl daemon-reload
sudo systemctl start grafana.service
```

Validate Grafana through Caddy, OIDC login, the Prometheus/VictoriaMetrics datasources, Loki logs, and full host reboot persistence.
