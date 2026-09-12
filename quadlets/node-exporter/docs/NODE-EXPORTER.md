# Node Exporter on Pasiv Black Box

Pasiv Black Box supplies an inactive Quadlet template for Prometheus Node Exporter. Node Exporter exposes hardware and operating-system metrics from the Pasiv host itself.

The supplied template uses the upstream image:

```text
quay.io/prometheus/node-exporter:latest
```

The validated design follows the upstream container pattern for host monitoring: host networking, the host PID namespace, and the host root filesystem mounted read-only at `/host`. The template does not publish a Podman port and does not grant extra Linux capabilities.

## Files

Template:

```text
/usr/share/pasiv-black-box/quadlets/node-exporter/node-exporter.container
```

Example Prometheus scrape job:

```text
/usr/share/pasiv-black-box/quadlets/node-exporter/examples/prometheus-job.yml
```

## Listen address placeholder

The public template intentionally contains this deployment placeholder:

```text
@@NODE_EXPORTER_LISTEN_ADDRESS@@
```

Replace it with the private host-side gateway address of the `pasiv-monitoring` Podman network before starting the service. Binding Node Exporter only to that private bridge address lets Prometheus containers reach the exporter without exposing TCP 9100 on the LAN or other host interfaces.

For example, inspect the monitoring network locally and use its gateway address:

```bash
sudo podman network inspect pasiv-monitoring
```

Do not commit site-specific addresses to the reusable public library.

## Deployment

Copy the Quadlet into the system Quadlet directory, replace the listen-address placeholder, reload systemd, and start the service:

```bash
sudo cp \
  /usr/share/pasiv-black-box/quadlets/node-exporter/node-exporter.container \
  /etc/containers/systemd/node-exporter.container
sudo sed -i \
  's/@@NODE_EXPORTER_LISTEN_ADDRESS@@/REPLACE_WITH_PRIVATE_BRIDGE_GATEWAY/' \
  /etc/containers/systemd/node-exporter.container
sudo systemctl daemon-reload
sudo systemctl start node-exporter.service
```

The supplied unit depends on `pasiv-monitoring-network.service` so the private bridge exists before Node Exporter binds its socket.

## Host access model

The template contains:

```ini
Network=host
PodmanArgs=--pid=host
Volume=/:/host:ro,rslave
SecurityLabelDisable=true
Exec=--path.rootfs=/host --path.udev.data=/host/run/udev/data --web.listen-address=@@NODE_EXPORTER_LISTEN_ADDRESS@@:9100
```

`Network=host` and `--pid=host` let collectors observe the host namespaces. The root filesystem is mounted read-only with `rslave` propagation so host mount changes remain visible. SELinux container labeling is disabled for this host-root bind mount; the host root must never be relabeled with `:Z` or `:z`.

`--path.udev.data=/host/run/udev/data` lets the diskstats collector read host udev metadata. Without this path, disk I/O metrics still work, but device model, serial, path, revision, and WWN fields can be missing.

The container receives no `CAP_SYS_TIME` or other additional capability. If a collector on a future host requires privileges that are not appropriate for Pasiv Black Box, prefer disabling that collector rather than broadening the container's privileges unless there is a separately validated reason to do so.

## Filesystem behavior on bootc hosts

On a bootc/composefs system, `/` can appear as a composefs-backed overlay mount. Node Exporter's default filesystem collector excludes `overlay`, so the root mount itself may not appear as a normal `node_filesystem_*` series.

That does not prevent monitoring the writable host filesystems. During validation, writable mounts such as `/var`, `/boot`, `/boot/efi`, and the dedicated monitoring-data filesystem were reported normally.

## Collector behavior

The reusable module keeps the upstream default collector set. This avoids baking one machine's hardware assumptions into the public template.

Collectors for subsystems that do not exist on a particular host can report `node_scrape_collector_success 0`. Examples can include NFS, ZFS, Fibre Channel, InfiniBand, IPVS, tape, bcache, kernel hung-task data, or PSI/pressure support.

Do not add host packages, filesystems, kernel features, or services only to make unused collectors report success. Evaluate collector failures against the capabilities actually intended for that Pasiv installation.

## Prometheus integration

Copy the supplied example into the local Prometheus `scrape_configs` section and replace the same listen-address placeholder:

```yaml
- job_name: node-exporter
  static_configs:
    - targets:
        - "@@NODE_EXPORTER_LISTEN_ADDRESS@@:9100"
```

Validate the complete Prometheus configuration with `promtool` before restarting Prometheus.

Useful host metrics include:

- `node_cpu_seconds_total`
- `node_load1`, `node_load5`, and `node_load15`
- `node_memory_MemTotal_bytes` and `node_memory_MemAvailable_bytes`
- `node_filesystem_*`
- `node_disk_*`
- `node_network_*`
- `node_hwmon_*`
- `node_uname_info`

## Validation

The supplied design was validated on physical Pasiv Black Box hardware with Node Exporter 1.12.1. Validation covered:

- host identity and kernel metrics;
- all host CPU cores and memory metrics;
- host physical-network-interface counters;
- host NVMe and SATA disk I/O;
- full disk udev metadata using `--path.udev.data=/host/run/udev/data`;
- writable host filesystem metrics, including the dedicated monitoring-data filesystem;
- available hardware temperature sensors;
- private-only binding on the monitoring bridge gateway;
- Prometheus scraping over that private bridge path;
- exporter restart recovery;
- automatic monitoring-network, Node Exporter, and Prometheus recovery after a full host reboot;
- zero failed systemd units after reboot.

The public template remains inactive and deliberately unresolved until the administrator replaces the listen-address placeholder for the local deployment.
