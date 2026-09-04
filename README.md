# Alma Black Box

A small, purpose-built monitoring and infrastructure-supervision appliance built on the official AlmaLinux 10 bootc image.

> [!IMPORTANT]
> AlmaLinux currently describes its bootc images as experimental. Alma Black Box should also be treated as experimental until it has been validated on your hardware and for your workload.

This project is intentionally **not** an all-purpose server distribution. The operating-system image contains host-level administration, power/UPS integration, networking, hardware diagnostics, and the Cockpit host bridge. Replaceable monitoring applications belong in Podman Quadlets.

## Architecture

```text
AlmaLinux 10 bootc
        |
Alma Black Box host layer
        |
NUT / UPSide / networking / diagnostics
        |
Podman + optional supplied Quadlets
```

## Native host layer

The image deliberately adds:

- NUT and NUT client
- UPSide Cockpit extension
- Tailscale
- NetBird
- WireGuard tools
- firewalld and NetworkManager
- fwupd
- smartmontools, lm_sensors, nvme-cli, usbutils, pciutils, ethtool and PowerTOP
- btop, micro, tmux, jq and rsync
- tcpdump, bind-utils, traceroute, nmap-ncat and iperf3
- SELinux administration tooling
- Cockpit system/bridge, networking, SELinux, files, Podman and storage pages
- Realtek USB Ethernet udev rules

Tailscale, NetBird, NUT, and the Cockpit web service are installed but not enrolled or configured by the generic image.

ZRAM is enabled with `zram-generator` using its built-in sizing policy: half of system RAM, capped at 4 GiB.

Cockpit is intentionally split: host bridge/pages are native, while the browser-facing `cockpit-ws` service is supplied as an inactive Quadlet template.

## What is not included

No Docker, Docker Compose, podman-compose, Distrobox, virtualization stack, ZFS, mergerfs, SnapRAID, Samba, NFS server, rclone, PCP, Grafana, Loki, Prometheus, or other application stacks are baked into the OS.

Replaceable monitoring applications should be deployed separately rather than added to the host image.

## Image

The current image is published as:

```text
ghcr.io/highwaytoit/alma-black-box:10
```

Each main-branch build also receives an immutable build tag such as:

```text
ghcr.io/highwaytoit/alma-black-box:10-20260902-abcdef1
```

Images are signed with Cosign.

## Installer ISO

A bootable unattended installer ISO can be generated on demand with the separate **Alma Black Box ISO Builder** template:

https://github.com/highwaytoit/alma-black-box-iso

Click **Use this template**, create a repository in your own GitHub account, then manually run **Build Alma Black Box installer ISO** from GitHub Actions. The template defaults to `ghcr.io/highwaytoit/alma-black-box:10` and resolves that tag to its current immutable digest at build time.

The installer is intentionally destructive. Review the ISO Builder README before use and ensure only the intended target disk is exposed to the installer.

The ISO Builder repository documents access options, partition sizing, signature verification, build artifacts, and installation behavior.

## Local documentation

Operational documentation is baked into every image at:

```text
/usr/share/alma-black-box/doc/
```

Supplied but inactive Quadlet templates are installed at:

```text
/usr/share/alma-black-box/quadlets/
```

The recommended deployment model is to copy a supplied template into `/etc/containers/systemd/`, customize the local copy, and leave the image-supplied template untouched.

See [docs/QUADLETS.md](docs/QUADLETS.md) and [docs/NUT-UPSide.md](docs/NUT-UPSide.md).

## Validation status

The image and installer have been exercised in a UEFI virtual machine. Installation, boot, SSH access, signed bootc updates, staged deployments, reboot into a new deployment, rollback retention, ZRAM activation, and basic system health checks have been verified.

Hardware-specific behavior should still be validated on each target system before relying on it for infrastructure monitoring or power management.

## Upstream projects

- AlmaLinux bootc: https://github.com/AlmaLinux/bootc-images
- AlmaLinux Atomic Desktop: https://github.com/AlmaLinux/atomic-desktop
- bootc: https://github.com/bootc-dev/bootc
- osbuild: https://github.com/osbuild
- Cockpit: https://github.com/cockpit-project/cockpit
- Network UPS Tools: https://github.com/networkupstools/nut
- UPSide: https://github.com/deviationist/cockpit-upside
- Tailscale: https://tailscale.com/
- NetBird: https://netbird.io/

The operating-system engineering belongs upstream. Alma Black Box intentionally remains a thin appliance layer.
