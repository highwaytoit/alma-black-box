# Alertmanager on Pasiv Black Box

Alertmanager receives alerts from Prometheus, groups and de-duplicates them, and routes notifications to configured receivers.

## Tested image

`docker.io/prom/alertmanager:latest`

Validated version: 0.34.0. The image runs as UID/GID 65534.

## Local paths

```text
/etc/pasiv-black-box/alertmanager/alertmanager.yml
/etc/pasiv-black-box/alertmanager/secrets/telegram-bot-token
/var/mnt/monitoring/alertmanager/
```

The supplied example uses Telegram. Replace the example chat ID locally and never commit a real bot token or chat ID.

The token file is mounted at `/run/secrets/telegram-bot-token`. In the validated deployment it remained owned by root, group-readable by numeric GID 65534, and mode `0640` so the non-root Alertmanager process could read it.

## Deploy

```bash
sudo cp \
  /usr/share/pasiv-black-box/quadlets/alertmanager/alertmanager.container \
  /etc/containers/systemd/alertmanager.container
sudo cp \
  /usr/share/pasiv-black-box/quadlets/alertmanager/examples/alertmanager.yml \
  /etc/pasiv-black-box/alertmanager/alertmanager.yml
sudo systemctl daemon-reload
sudo systemctl start alertmanager.service
```

The tested deployment received Prometheus alerts, delivered both firing and resolved Telegram notifications, returned `OK` from its readiness endpoint, and remained healthy after a full host reboot.
