# Pasiv Black Box Quadlet library

The image ships a reusable library of inactive system Quadlet templates under `/usr/share/pasiv-black-box/quadlets/`. Nothing in this library starts automatically.

| Module | Template | Documentation | Example configuration |
| --- | --- | --- | --- |
| Cockpit | `cockpit/cockpit.container` | `cockpit/docs/COCKPIT.md` | - |
| Monitoring network | `network/pasiv-monitoring.network` | `network/docs/NETWORK.md` | - |
| Caddy | `caddy/caddy.container` | `caddy/docs/CADDY.md` | local `Caddyfile` + env file |
| Authelia | `authelia/authelia.container` | `authelia/docs/AUTHELIA.md` | documented local config/secrets |
| Grafana | `grafana/grafana.container` | `grafana/docs/GRAFANA.md` | documented local env file |
| Prometheus | `prometheus/prometheus.container` | `prometheus/docs/PROMETHEUS.md` | `prometheus/examples/prometheus.yml` |
| Loki | `loki/loki.container` | `loki/docs/LOKI.md` | documented local config |
| Grafana Alloy | `alloy/alloy.container` | `alloy/docs/ALLOY.md` | documented local config |
| VictoriaMetrics | `victoriametrics/victoriametrics.container` | `victoriametrics/docs/VICTORIAMETRICS.md` | - |
| Alertmanager | `alertmanager/alertmanager.container` | `alertmanager/docs/ALERTMANAGER.md` | `alertmanager/examples/alertmanager.yml` |

## Intended use

1. Read the service documentation.
2. Copy the required template and any example configuration to local administrator-owned paths.
3. Replace examples/placeholders and add deployment-specific secrets locally.
4. Apply the documented storage ownership and SELinux labels.
5. Run `systemctl daemon-reload` and start the generated service.
6. Validate the service before enabling or depending on it.

The monitoring application templates in this library were derived from configurations validated on a real Pasiv Black Box deployment, including restart and host reboot testing. The public versions are sanitized and do not contain deployment domains, credentials, tokens, account names, private chat IDs, or site-specific addresses.

The library is intentionally modular so individual service directories can later be moved to a shared repository without changing their internal layout.
