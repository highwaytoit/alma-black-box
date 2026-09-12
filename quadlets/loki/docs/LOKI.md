# Loki on Pasiv Black Box

Loki stores logs collected by Grafana Alloy and exposes them to Grafana over the private `pasiv-monitoring` network.

## Tested image

`docker.io/grafana/loki:latest`

Validated version: 3.7.7. The image runs as UID 10001.

## Local paths

```text
/etc/pasiv-black-box/loki/loki.yml
/var/mnt/monitoring/loki/
```

A known-working single-node configuration uses TSDB schema v13, filesystem object storage, replication factor 1, and `/loki` as the path prefix.

## Deploy

```bash
sudo cp \
  /usr/share/pasiv-black-box/quadlets/loki/loki.container \
  /etc/containers/systemd/loki.container
sudo systemctl daemon-reload
sudo systemctl start loki.service
```

Loki may report `Ingester not ready: waiting for 15s after being ready` briefly after startup. Recheck the `/ready` endpoint after the grace period.

The validated stack received systemd-journal data from Alloy and returned series labeled with `job="loki.source.journal.system"` and `host="pasiv-black-box"` after the product rename and reboot test.
