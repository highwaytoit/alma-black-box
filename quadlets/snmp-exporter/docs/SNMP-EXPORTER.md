# SNMP Exporter on Pasiv Black Box

Pasiv Black Box supplies an inactive Quadlet template for Prometheus SNMP Exporter. SNMP Exporter polls SNMP-enabled network devices and exposes the returned data as Prometheus metrics.

The supplied template uses the upstream image:

```text
quay.io/prometheus/snmp-exporter:latest
```

It joins the private `pasiv-monitoring` Podman network with the alias `snmp-exporter`. TCP 9116 is intentionally not published on the host. Prometheus or other monitoring components on the same private network can reach it as `snmp-exporter:9116`.

## Files

Template:

```text
/usr/share/pasiv-black-box/quadlets/snmp-exporter/snmp-exporter.container
```

Example SNMPv3 auth configuration:

```text
/usr/share/pasiv-black-box/quadlets/snmp-exporter/examples/snmp-auth.yml
```

Example environment file:

```text
/usr/share/pasiv-black-box/quadlets/snmp-exporter/examples/snmp.env.example
```

Recommended local paths:

```text
/etc/pasiv-black-box/snmp-exporter/snmp-auth.yml
/etc/pasiv-black-box/snmp-exporter/snmp.env
```

The template keeps the upstream generated `/etc/snmp_exporter/snmp.yml` untouched and loads a second local auth-only configuration file. This keeps device credentials separate from the generated module library.

## Deployment

Copy the examples and Quadlet into local administrator-owned paths:

```bash
sudo install -d -m0755 /etc/pasiv-black-box/snmp-exporter
sudo cp \
  /usr/share/pasiv-black-box/quadlets/snmp-exporter/examples/snmp-auth.yml \
  /etc/pasiv-black-box/snmp-exporter/snmp-auth.yml
sudo cp \
  /usr/share/pasiv-black-box/quadlets/snmp-exporter/examples/snmp.env.example \
  /etc/pasiv-black-box/snmp-exporter/snmp.env
sudo chown root:root /etc/pasiv-black-box/snmp-exporter/snmp.env
sudo chmod 0600 /etc/pasiv-black-box/snmp-exporter/snmp.env
sudo cp \
  /usr/share/pasiv-black-box/quadlets/snmp-exporter/snmp-exporter.container \
  /etc/containers/systemd/snmp-exporter.container
sudo systemctl daemon-reload
sudo systemctl start snmp-exporter.service
```

Replace the placeholder username and passwords before starting the service. Do not commit the real environment file to a public repository.

## SNMPv3 example for RouterOS

SNMPv3 `authPriv` keeps authentication and privacy enabled. A sanitized RouterOS example is:

```routeros
/snmp community disable [find where name="public"]
/snmp community add \
    name=monitoring-snmp \
    addresses=192.0.2.10/32 \
    security=private \
    authentication-protocol=SHA1 \
    authentication-password="CHANGE_ME_AUTH_PASSWORD" \
    encryption-protocol=AES \
    encryption-password="CHANGE_ME_PRIV_PASSWORD" \
    read-access=yes \
    write-access=no
/snmp set enabled=yes
```

Use the monitoring host address for `addresses=` and keep the entry read-only. The default unauthenticated `public` community should remain disabled when SNMPv3 is used.

The matching exporter auth profile is supplied as `monitoring_v3`. RouterOS names the authentication algorithm `SHA1`; SNMP Exporter uses `SHA` for the corresponding auth protocol value.

## Prometheus integration

SNMP Exporter uses the multi-target exporter pattern. Prometheus sends the real device address as the `target` query parameter and scrapes SNMP Exporter itself through the private monitoring network.

The exporter itself can be scraped directly:

```yaml
- job_name: snmp-exporter
  static_configs:
    - targets:
        - snmp-exporter:9116
```

Example device scrape using the three modules validated against RouterOS hardware:

```yaml
- job_name: snmp-router
  metrics_path: /snmp
  params:
    auth:
      - monitoring_v3
    module:
      - system
      - if_mib
      - mikrotik
  static_configs:
    - targets:
        - 192.0.2.1
  relabel_configs:
    - source_labels:
        - __address__
      target_label: __param_target
    - source_labels:
        - __param_target
      target_label: instance
    - target_label: __address__
      replacement: snmp-exporter:9116
```

The `system` module supplies standard system data such as uptime and identity. `if_mib` supplies interface state and traffic counters. The `mikrotik` module supplies RouterOS-specific metrics such as board, firmware, hardware health, DHCP lease count, and vendor interface statistics.

Keep site-specific device addresses and credentials in local deployment configuration. The generic Prometheus module remains independent from SNMP Exporter.

## Host diagnostic tools

Pasiv Black Box also includes `net-snmp-utils` in the host toolset. `snmpget` and `snmpwalk` are useful for proving SNMP connectivity and credentials independently of the exporter when troubleshooting.

## Validation

The supplied design was validated on physical Pasiv Black Box hardware with SNMP Exporter 0.30.1 and a MikroTik RouterOS device. Validation covered:

- direct SNMPv3 `authPriv` access using SHA authentication and AES privacy;
- source-address restriction to the monitoring host;
- exporter self-metrics;
- `system` module polling;
- `if_mib` interface state and 64-bit traffic counters;
- MikroTik-specific `mikrotik` module metrics;
- Prometheus service discovery over `pasiv-monitoring`;
- successful Prometheus exporter and router targets;
- RouterOS metrics reaching Prometheus;
- automatic recovery after an exporter restart;
- automatic SNMP Exporter and Prometheus recovery after a full host reboot.

A short target failure can appear during a container restart while Podman DNS and the replacement container endpoint converge. Confirm recovery across subsequent scrape cycles before treating that transition as a persistent monitoring failure.
