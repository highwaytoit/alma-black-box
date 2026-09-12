# Grafana Alloy on Pasiv Black Box

Grafana Alloy reads the host systemd journal and forwards log entries to Loki.

## Tested image

`docker.io/grafana/alloy:latest`

Validated version: 1.19.2.

## Local configuration

Create `/etc/pasiv-black-box/alloy/config.alloy`. A known-working minimal configuration is:

```alloy
loki.write "default" {
  endpoint {
    url = "http://loki:3100/loki/api/v1/push"
  }
}

loki.source.journal "system" {
  path = "/var/log/journal"
  forward_to = [loki.write.default.receiver]
  labels = {
    job = "systemd-journal",
    host = "pasiv-black-box",
  }
}
```

Change the `host` label if the deployed hostname differs.

The supplied Quadlet intentionally uses `SecurityLabelDisable=true` for read-only system journal access. It does not run privileged and does not relabel the host journal.

## Deploy

```bash
sudo cp \
  /usr/share/pasiv-black-box/quadlets/alloy/alloy.container \
  /etc/containers/systemd/alloy.container
sudo systemctl daemon-reload
sudo systemctl start alloy.service
```

Validate in Grafana/Loki by querying the journal series and confirming current host logs arrive after restart and reboot.
