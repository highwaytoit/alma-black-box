# Cockpit web service on Pasiv Black Box

Pasiv Black Box installs the native Cockpit bridge, system pages, Podman integration, storage integration, and UPSide extension. The browser-facing Cockpit web service is supplied separately as an inactive Podman Quadlet template.

The template is installed at:

```text
/usr/share/pasiv-black-box/quadlets/cockpit/cockpit.container
```

Copy it into the active system Quadlet directory before use:

```bash
sudo cp \
  /usr/share/pasiv-black-box/quadlets/cockpit/cockpit.container \
  /etc/containers/systemd/cockpit.container
sudo systemctl daemon-reload
sudo systemctl start cockpit.service
```

The image build replaces `@@COCKPIT_WS_IMAGE@@` with the validated Cockpit web-service image reference.

## Security model

The upstream `cockpit/ws` container model needs broad host access to provide a real host administration session. The supplied template therefore uses host PID access, mounts the host root filesystem at `/host`, and runs privileged.

This is intentional for Cockpit and should not be copied as a pattern for ordinary application containers.

Pasiv Black Box permits SSH password authentication only from localhost so the Cockpit container can authenticate local host accounts without enabling network SSH password login.

Review the active firewalld zone before exposing TCP 9090. Only expose Cockpit on networks that are intended to administer the appliance.

## Validation

After starting the Quadlet:

```bash
systemctl status cockpit.service --no-pager
sudo podman ps --filter name=cockpit-ws
```

Then open the appliance on TCP 9090 from an allowed management network and authenticate with the intended local host account.
