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

## Local SSH and shell output

The Cockpit web-service container starts `cockpit-ws` in `--local-ssh` mode. Authentication therefore uses SSH to `127.0.0.1`, and the host `cockpit-bridge` is started through that non-interactive SSH session.

Non-interactive SSH stdout must stay clean. Login banners, `fastfetch`, `neofetch`, or similar commands must not write to stdout for non-interactive SSH commands or they can corrupt the Cockpit protocol stream.

For Bash, keep Fastfetch limited to interactive shells:

```bash
if [[ $- == *i* ]]; then fastfetch; fi
```

A quick verification is:

```bash
ssh 127.0.0.1 'printf "__ONLY_THIS__\n"'
```

After authentication, the command should print only `__ONLY_THIS__`.

## Real-machine validation

The supplied Cockpit Quadlet was revalidated on a physical Pasiv Black Box appliance without changes to the template.

Validated behavior included:

- local-account login through the containerized Cockpit web service;
- administrative access elevation;
- Overview, Storage, Networking, Services, Logs, Accounts, and Terminal pages;
- Podman container visibility and container detail pages;
- File browser access to the monitoring storage tree;
- UPSide extension loading;
- automatic Quadlet startup after host reboot;
- clean reboot with no failed systemd units.

## Validation

After starting the Quadlet:

```bash
systemctl status cockpit.service --no-pager
sudo podman ps --filter name=cockpit-ws
systemctl --failed --no-pager
```

Then open the appliance on TCP 9090 from an allowed management network and authenticate with the intended local host account.

For a complete validation, also confirm administrative access, File browser, Podman, Storage, UPSide, Terminal, and a host reboot with Cockpit returning automatically.
