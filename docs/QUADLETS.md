# Supplied Quadlets

Alma Black Box keeps inactive Quadlet templates under:

```text
/usr/share/alma-black-box/quadlets/
```

They are deliberately outside Podman's active Quadlet search directories.

## Recommended deployment

Copy the desired template into `/etc/containers/systemd/`, then customize the local copy for the deployment:

```bash
sudo mkdir -p /etc/containers/systemd
sudo cp /usr/share/alma-black-box/quadlets/cockpit.container \
  /etc/containers/systemd/cockpit.container
sudo micro /etc/containers/systemd/cockpit.container
sudo systemctl daemon-reload
sudo systemctl start cockpit.service
```

The copied file belongs to the local administrator. Future Alma Black Box image updates can refresh the supplied template under `/usr/share/alma-black-box/quadlets/` without overwriting the active local copy.

## Symlink deployment

A supplied template can instead be symlinked into `/etc/containers/systemd/`:

```bash
sudo mkdir -p /etc/containers/systemd
sudo ln -s /usr/share/alma-black-box/quadlets/cockpit.container \
  /etc/containers/systemd/cockpit.container
sudo systemctl daemon-reload
sudo systemctl start cockpit.service
```

With a symlink, a future bootc image update can change the supplied template and therefore change the active service definition. Use this model only when that behavior is intentional.

## Cockpit web service

The supplied Cockpit template follows the upstream privileged `cockpit/ws` container model, including host PID access and the host filesystem mounted at `/host`.

Alma Black Box installs the native Cockpit bridge/system components and the UPSide extension. The `cockpit-ws` container supplies the browser-facing web service.

The image permits SSH password authentication only from localhost so the Cockpit container can authenticate host users without enabling SSH password access from the network.

Before browser login, ensure the intended host account has suitable credentials. Open TCP port 9090 only on networks where Cockpit should be reachable, and review the active firewalld zone before changing firewall rules.

## Template policy

Supplied templates are intentionally generic. Storage paths, secrets, ports, network exposure, SELinux requirements, capabilities, and application-specific settings should be reviewed and adapted by the administrator before activation.
