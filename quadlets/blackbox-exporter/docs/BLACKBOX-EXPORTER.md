# Blackbox Exporter on Pasiv Black Box

Pasiv Black Box supplies an inactive Quadlet template for Prometheus Blackbox Exporter. Blackbox Exporter performs active probes of remote endpoints and exposes the results as Prometheus metrics.

The supplied template uses the upstream image:

```text
quay.io/prometheus/blackbox-exporter:latest
```

It joins the private `pasiv-monitoring` Podman network with the alias `blackbox-exporter`. TCP 9115 is intentionally not published on the host. Prometheus or other monitoring components on the same private network can reach it as `blackbox-exporter:9115`.

## Files

Template:

```text
/usr/share/pasiv-black-box/quadlets/blackbox-exporter/blackbox-exporter.container
```

Example probe configuration:

```text
/usr/share/pasiv-black-box/quadlets/blackbox-exporter/examples/blackbox.yml
```

Recommended local configuration path:

```text
/etc/pasiv-black-box/blackbox-exporter/blackbox.yml
```

## Deployment

Copy the example configuration and Quadlet into local administrator-owned paths:

```bash
sudo install -d -m0755 /etc/pasiv-black-box/blackbox-exporter
sudo cp \
  /usr/share/pasiv-black-box/quadlets/blackbox-exporter/examples/blackbox.yml \
  /etc/pasiv-black-box/blackbox-exporter/blackbox.yml
sudo cp \
  /usr/share/pasiv-black-box/quadlets/blackbox-exporter/blackbox-exporter.container \
  /etc/containers/systemd/blackbox-exporter.container
sudo systemctl daemon-reload
sudo systemctl start blackbox-exporter.service
```

The supplied example contains four modules that were exercised on physical Pasiv Black Box hardware: HTTP/HTTPS, TCP connect, ICMP, and DNS.

## ICMP permissions

On Linux, Blackbox Exporter ICMP probing requires either an allowed `net.ipv4.ping_group_range`, `CAP_NET_RAW`, or root privileges. Do not grant extra container privileges by default.

The physical Pasiv validation host already allowed unprivileged ping through `net.ipv4.ping_group_range`, so the supplied Quadlet required neither `CAP_NET_RAW` nor privileged mode. Check the deployed host first and add only the minimum permission actually required.

## Prometheus integration

Blackbox Exporter uses the multi-target exporter pattern. Prometheus sends the real probe target as the `target` query parameter and scrapes Blackbox Exporter itself through the private network.

Example HTTP job:

```yaml
- job_name: blackbox-http
  metrics_path: /probe
  params:
    module:
      - http_2xx
  static_configs:
    - targets:
        - https://example.com
  relabel_configs:
    - source_labels:
        - __address__
      target_label: __param_target
    - source_labels:
        - __param_target
      target_label: instance
    - target_label: __address__
      replacement: blackbox-exporter:9115
```

Use the same relabel pattern with the `tcp_connect`, `icmp`, or `dns_a` module and deployment-appropriate targets. Keep the generic Prometheus module independent; site-specific target lists belong in local deployment configuration.

The exporter itself can also be scraped directly:

```yaml
- job_name: blackbox-exporter
  static_configs:
    - targets:
        - blackbox-exporter:9115
```

## Validation

The supplied design was validated on physical Pasiv Black Box hardware with Blackbox Exporter 0.28.0. Validation covered:

- exporter self-metrics;
- HTTP/HTTPS probe success and HTTP status reporting;
- TCP connect probing;
- ICMP probing without additional capabilities on the tested host;
- DNS probing;
- Prometheus service discovery over `pasiv-monitoring`;
- Prometheus `probe_success=1` for all four probe types;
- automatic Blackbox Exporter and Prometheus recovery after a full host reboot.

For a deployed target, check both Prometheus target health and the `probe_success` metric. A successful scrape of `/probe` does not by itself prove that the remote target probe succeeded.
