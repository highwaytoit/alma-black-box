# Supplied Quadlets

Pasiv Black Box keeps inactive Quadlet templates under:

```text
/usr/share/pasiv-black-box/quadlets/<service>/
```

They are deliberately outside Podman's active Quadlet search directories. Each service directory keeps its Quadlet template together with its service-specific documentation and optional example configuration.

See [QUADLET-LIBRARY.md](QUADLET-LIBRARY.md) for the complete module index.

## Recommended deployment: copy and customize

Copy the desired template into `/etc/containers/systemd/`, then customize the local copy for the deployment. For example:

```bash
sudo mkdir -p /etc/containers/systemd
sudo cp \
  /usr/share/pasiv-black-box/quadlets/cockpit/cockpit.container \
  /etc/containers/systemd/cockpit.container
sudo micro /etc/containers/systemd/cockpit.container
sudo systemctl daemon-reload
sudo systemctl start cockpit.service
```

The copied file belongs to the local administrator. Future Pasiv Black Box image updates can refresh the supplied template without overwriting the active local copy.

## Optional symlink deployment

A supplied template can instead be symlinked into `/etc/containers/systemd/`:

```bash
sudo ln -s \
  /usr/share/pasiv-black-box/quadlets/cockpit/cockpit.container \
  /etc/containers/systemd/cockpit.container
sudo systemctl daemon-reload
sudo systemctl start cockpit.service
```

> [!CAUTION]
> With a symlink, a future bootc image update can change the supplied template and therefore change the active service definition. Use this model only when that behavior is intentional.

## Shared monitoring network

Several monitoring templates use `Network=pasiv-monitoring.network`. Deploy the supplied network Quadlet first when using those modules:

```text
/usr/share/pasiv-black-box/quadlets/network/pasiv-monitoring.network
```

Copy it to `/etc/containers/systemd/pasiv-monitoring.network`, reload systemd, and start `pasiv-monitoring-network.service` before starting dependent application Quadlets.

## Template policy

Supplied templates are intentionally generic and inactive. Storage paths, secrets, ports, network exposure, SELinux requirements, capabilities, authentication settings, and application-specific configuration must be reviewed and adapted by the administrator before activation.

Do not place deployment secrets in the public library or directly in Quadlet files when the application supports protected environment or secret files.
