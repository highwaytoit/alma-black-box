# Prometheus on Pasiv Black Box

Prometheus is the primary scraper and alert-rule evaluator in the validated Pasiv monitoring stack.

## Tested image

`docker.io/prom/prometheus:latest`

Validated version: 3.14.0. The image runs as UID/GID 65534.

## Local paths

```text
/etc/pasiv-black-box/prometheus/prometheus.yml
/etc/pasiv-black-box/prometheus/rules/
/var/mnt/monitoring/prometheus/
```

The supplied example configuration enables Prometheus self-scraping, rule loading, Alertmanager delivery, and VictoriaMetrics `remote_write`.

## Deploy

```bash
sudo cp \
  /usr/share/pasiv-black-box/quadlets/prometheus/prometheus.container \
  /etc/containers/systemd/prometheus.container
sudo cp \
  /usr/share/pasiv-black-box/quadlets/prometheus/examples/prometheus.yml \
  /etc/pasiv-black-box/prometheus/prometheus.yml
sudo systemctl daemon-reload
sudo systemctl start prometheus.service
```

Validate configuration with:

```bash
sudo podman exec prometheus promtool check config /etc/prometheus/prometheus.yml
```

The tested deployment discovered Alertmanager at `http://alertmanager:9093/api/v2/alerts`, successfully remote-wrote the `up` series to VictoriaMetrics, and survived a full host reboot.
