# Supplied Quadlets

Alma Black Box keeps inactive, project-tested Quadlet templates under:

```text
/usr/share/alma-black-box/quadlets/
```

They are deliberately outside Podman's active Quadlet search directories.

## Option A: copy and customize

Use this when the deployment needs local changes.

```bash
sudo mkdir -p /etc/containers/systemd
sudo cp /usr/share/alma-black-box/quadlets/cockpit.container \
  /etc/containers/systemd/cockpit.container
sudo micro /etc/containers/systemd/cockpit.container
sudo systemctl daemon-reload
sudo systemctl start cockpit.service
```

The copied file belongs to the local administrator. Future OS updates will update the supplied template but will not overwrite the local copy.

## Option B: symlink the supplied template

Use this when the project default is exactly what you want and you intentionally want future image updates to change the active definition.

```bash
sudo mkdir -p /etc/containers/systemd
sudo ln -s /usr/share/alma-black-box/quadlets/cockpit.container \
  /etc/containers/systemd/cockpit.container
sudo systemctl daemon-reload
sudo systemctl start cockpit.service
```

## Cockpit v1 notes

The v1 Cockpit template follows Cockpit upstream's privileged `cockpit/ws` container model: privileged container, host PID namespace, and the host filesystem mounted at `/host`.

Alma Black Box installs the native Cockpit bridge/system, networking, SELinux, files, Podman and storage pages, plus the UPSide extension. AlmaLinux packages the networking and SELinux components as part of `cockpit-system`; `cockpit-files`, `cockpit-podman`, and `cockpit-storaged` remain separate native packages. The `cockpit-ws` container supplies the browser-facing web service.

The image permits SSH password authentication only from localhost so the Cockpit container can authenticate host users without enabling SSH password access from the network.

Before testing browser login, set a password for the intended host account if it does not already have one.

Open TCP port 9090 only on the networks where you actually want Cockpit reachable. For example, review your active firewalld zone before adding the port.

## Template acceptance policy

Future Quadlets should be added here only after they have been deployed and tested on an Alma Black Box test VM or bare-metal test node. Documentation should record the initial test date/version. A later upstream application update can still break an old template; report that as an issue and revalidate the template.
