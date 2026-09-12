# VictoriaMetrics on Pasiv Black Box

The tested deployment uses single-node VictoriaMetrics as a Prometheus-compatible metrics store behind the private monitoring network.

## Tested image

`docker.io/victoriametrics/victoria-metrics:latest`

Validated version: 1.151.0.

## Storage

Persistent data lives at:

`/var/mnt/monitoring/victoriametrics`

The Quadlet mounts it at `/victoria-metrics-data` and listens internally on port 8428. No host port is published.

## Deploy

```bash
sudo cp \
  /usr/share/pasiv-black-box/quadlets/victoriametrics/victoriametrics.container \
  /etc/containers/systemd/victoriametrics.container
sudo systemctl daemon-reload
sudo systemctl start victoriametrics.service
```

Prometheus can remote-write to:

`http://victoriametrics:8428/api/v1/write`

Grafana can use:

`http://victoriametrics:8428`

as a Prometheus-compatible datasource.

The validated deployment returned the Prometheus `up` series successfully, reported `VictoriaMetrics is Ready.`, and survived full host reboot testing.
