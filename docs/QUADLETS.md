# Supplied Quadlets

Alma Black Box keeps inactive, project-tested Quadlet templates under:

```text
/usr/share/alma-black-box/quadlets/
```

They are deliberately outside Podman's active Quadlet search directories.

## Recommended: copy and customize

Copying is the recommended deployment model.

```bash
sudo mkdir -p /etc/containers/systemd
sudo cp /usr/share/alma-black-box/quadlets/cockpit.container \
  /etc/containers/systemd/cockpit.container
sudo micro /etc/containers/systemd/cockpit.container
sudo systemctl daemon-reload
sudo systemctl start cockpit.service
```

The copied file belongs to the local administrator and can be customized for that machine. Future Alma Black Box image updates will update the supplied template under `/usr/share/alma-black-box/quadlets/` but will not overwrite the active local copy under `/etc/containers/systemd/`.

This separation is intentional. Supplied templates are project defaults and documentation; active Quadlets are local configuration.

## Optional but not recommended: symlink the supplied template

A supplied template can be symlinked directly into `/etc/containers/systemd/`, but this deployment model is not recommended.

```bash
sudo mkdir -p /etc/containers/systemd
sudo ln -s /usr/share/alma-black-box/quadlets/cockpit.container \
  /etc/containers/systemd/cockpit.container
sudo systemctl daemon-reload
sudo systemctl start cockpit.service
```

With a symlink, a future bootc image update can change the supplied template and therefore change the active service definition. Use this only when that behavior is explicitly desired and the administrator is prepared to review template changes before or after image updates.

## Cockpit v1 notes

The v1 Cockpit template follows Cockpit upstream's privileged `cockpit/ws` container model: privileged container, host PID namespace, and the host filesystem mounted at `/host`.

Alma Black Box installs the native Cockpit bridge/system, networking, SELinux, files, Podman and storage pages, plus the UPSide extension. AlmaLinux packages the networking and SELinux components as part of `cockpit-system`; `cockpit-files`, `cockpit-podman`, and `cockpit-storaged` remain separate native packages. The `cockpit-ws` container supplies the browser-facing web service.

The image permits SSH password authentication only from localhost so the Cockpit container can authenticate host users without enabling SSH password access from the network.

Before testing browser login, set a password for the intended host account if it does not already have one.

Open TCP port 9090 only on the networks where you actually want Cockpit reachable. For example, review your active firewalld zone before adding the port.

## Template acceptance policy

Future Quadlets should be added here only after they have been deployed and tested on an Alma Black Box test VM or bare-metal test node. Documentation should record the initial test date/version. A later upstream application update can still break an old template; report that as an issue and revalidate the template.

See `QUADLET-STATUS.md` for the planned and validated template inventory.
