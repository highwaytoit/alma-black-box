# Version 1 VM validation

Keep the first VM after validation. It becomes the long-lived test target for future image updates and new Quadlet templates.

## 1. Boot and base identity

Verify the VM boots normally, obtains networking, and reports the expected AlmaLinux/bootc identity.

Useful checks:

```bash
cat /etc/os-release
sudo bootc status
systemctl --failed --no-pager
```

## 2. Native capabilities

Verify the expected commands are available:

```bash
command -v upsc nut-scanner tailscale netbird fwupdmgr smartctl sensors nvme
command -v lsusb lspci ethtool powertop btop micro tmux
command -v tcpdump dig traceroute nc iperf3 semanage cockpit-bridge
```

Confirm Tailscale and NetBird are not enrolled merely by booting the image.

## 3. Cockpit Quadlet

For the first test, copy the supplied template rather than symlinking it. This makes local debugging easy.

```bash
sudo mkdir -p /etc/containers/systemd
sudo cp /usr/share/alma-black-box/quadlets/cockpit.container \
  /etc/containers/systemd/cockpit.container
sudo systemctl daemon-reload
sudo systemctl start cockpit.service
sudo systemctl status cockpit.service --no-pager
sudo podman ps
```

Set a password for the account used for Cockpit login if necessary. Then permit TCP 9090 in the appropriate firewalld zone for the VM test and browse to the VM on port 9090.

Verify that the normal host pages render and that the UPSide extension is visible. UPS data is not expected in the VM unless a UPS is intentionally passed through.

## 4. Reboot persistence

Reboot the VM and verify the Cockpit Quadlet returns automatically and there are no failed systemd units.

## 5. Atomic update test

After version 1 is confirmed, keep this VM. Publish version 2 with a harmless, identifiable change plus the next set of tested features.

Then verify:

```bash
sudo bootc upgrade
sudo bootc status
sudo reboot
sudo bootc status
```

Confirm the new deployment booted and the previous deployment remains available for rollback. Exercise rollback once before using the image on bare metal.

## 6. Hardware-enablement follow-up

Do not guess about extra Wi-Fi firmware in version 1. Inspect the completed image and the physical Lenovo later. Add firmware packages only if the standard Alma bootc image does not already provide the desired hardware support.
