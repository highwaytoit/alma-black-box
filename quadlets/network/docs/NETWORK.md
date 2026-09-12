# Pasiv Black Box private monitoring network

This guide documents the shared Podman Quadlet network used by Pasiv Black Box monitoring applications.

The supplied template is:

`/usr/share/pasiv-black-box/quadlets/network/pasiv-monitoring.network`

The recommended deployment model is copy-and-customize. Do not symlink the supplied template into the active Quadlet directory because a later bootc image update could change the supplied definition underneath an active service.

## Purpose

`pasiv-monitoring` is a private Podman bridge network used by monitoring and support services such as Caddy, Authelia, Grafana, Prometheus, Loki, OpenClaw, and workflow tools.

Podman DNS is enabled on the bridge, so containers can reach one another by network alias without publishing every application port to the host.

The network is intentionally not marked `internal`. Some monitoring services need outbound access to LAN devices, DNS, GitHub/GHCR, Telegram, cloud AI providers, certificate authorities, or other external endpoints.

## Supplied Quadlet

```ini
[Unit]
Description=Pasiv Black Box private monitoring network

[Network]
NetworkName=pasiv-monitoring
Driver=bridge
```

## Activate the network

Copy the supplied template:

```bash
sudo cp /usr/share/pasiv-black-box/quadlets/network/pasiv-monitoring.network \
  /etc/containers/systemd/pasiv-monitoring.network
```

Reload systemd:

```bash
sudo systemctl daemon-reload
```

Start the generated network service:

```bash
sudo systemctl start pasiv-monitoring-network.service
```

## Verify

Check the generated systemd unit:

```bash
systemctl status pasiv-monitoring-network.service --no-pager
```

For a network Quadlet, `active (exited)` is normal. The generated service creates the Podman network and then exits successfully; the network itself remains available in Podman.

Inspect the network:

```bash
sudo podman network inspect pasiv-monitoring
```

List Podman networks:

```bash
sudo podman network ls
```

Expected properties include:

- network name: `pasiv-monitoring`
- driver: `bridge`
- DNS enabled
- not internal

The exact subnet is allocated by Podman and should not be hard-coded into application configuration unless there is a specific reason.

## Using the network from an application Quadlet

A service joins the network with:

```ini
Network=pasiv-monitoring.network
NetworkAlias=example-service
```

Other containers on `pasiv-monitoring` can then reach the service by its alias, for example:

```text
example-service:3000
```

This lets Caddy reverse-proxy human-facing applications while Prometheus, Loki, exporters, and other machine-to-machine endpoints can remain unpublished on the host.

## Reboot behavior

A container Quadlet that declares:

```ini
Network=pasiv-monitoring.network
```

causes the generated application service to depend on `pasiv-monitoring-network.service`.

Verify with:

```bash
systemctl show <service>.service -p Requires -p After
```

## Remove the active network

First stop any containers that use the network. Then remove the active Quadlet definition:

```bash
sudo rm /etc/containers/systemd/pasiv-monitoring.network
sudo systemctl daemon-reload
```

If the Podman network is no longer used and should also be deleted:

```bash
sudo podman network rm pasiv-monitoring
```

Do not remove the network while active services still depend on it.

## Validation status

This design was validated on bare-metal Pasiv Black Box with Podman Quadlet and SELinux enforcing. A successful test showed the generated systemd service as `active (exited)`, Podman DNS enabled, and dependent container services starting correctly after reboot.
