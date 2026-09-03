# Alma Black Box

A small, purpose-built monitoring and infrastructure-supervision appliance built on the official AlmaLinux 10 bootc image.

> [!IMPORTANT]
> AlmaLinux currently describes its bootc images as experimental. Alma Black Box should also be treated as experimental until it has been validated on your hardware and for your workload.

This project is intentionally **not** an all-purpose server distribution. The operating-system image contains only host-level administration, power/UPS, networking, hardware diagnostics, and the Cockpit host bridge. Replaceable monitoring applications belong in Podman Quadlets.

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

Version 1 intentionally ships only one application Quadlet template: Cockpit's web service. The broader monitoring library will be added only after each Quadlet has been tested.

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

Tailscale, NetBird, NUT, and the Cockpit web service are not enrolled/configured or automatically activated by the generic image.

Cockpit is intentionally split: host bridge/pages are native, while the browser-facing `cockpit-ws` service is supplied as a Quadlet. This allows UPSide and the host-specific Cockpit pages to work without running the native Cockpit web server.

## What is not included

No Docker, Docker Compose, podman-compose, Distrobox, virtualization stack, ZFS, mergerfs, SnapRAID, Samba, NFS server, rclone, PCP, Grafana, Loki, Prometheus, or other application stacks are baked into the OS.

Future monitoring applications will be shipped as inactive, tested Quadlet templates rather than native packages.

## Image

After the first successful build, the current image will be published as:

```text
ghcr.io/highwaytoit/alma-black-box:10
```

Each main-branch build also receives an immutable build tag such as:

```text
ghcr.io/highwaytoit/alma-black-box:10-20260902-abcdef1
```

Images are signed with Cosign.

## Installer ISO

A separate osbuild workflow produces an unattended UEFI `bootc-installer` ISO. A dedicated AlmaLinux bootc installer container provides Anaconda/Lorax for ISO construction, while the signed `:10` Alma Black Box image remains the separate verified installation payload.

The installer is deliberately destructive and is intended to see only one target disk. Its v1 layout is 512 MiB EFI, 1 GiB `/boot`, and XFS `/` using the remainder of the disk. The temporary local administrator is `bbox` with password `bbox`; root is locked and the temporary password should be changed immediately after first boot.

See [docs/INSTALLER.md](docs/INSTALLER.md) before booting the ISO.

## Local documentation

The same operational documentation is baked into every image at:

```text
/usr/share/doc/alma-black-box/
```

Supplied but inactive Quadlet templates are installed at:

```text
/usr/share/alma-black-box/quadlets/
```

See [docs/QUADLETS.md](docs/QUADLETS.md) for the supported copy and symlink deployment models.

## Version 1 test objective

Version 1 is deliberately narrow. It should prove:

1. The custom Alma bootc image builds and is signed.
2. The installer ISO installs the image correctly in a UEFI VM with the intended partition layout.
3. The installed image boots in a VM.
4. Native host tools are present.
5. Tailscale and NetBird are installed but not enrolled.
6. NUT and UPSide are present but not hardware-configured.
7. The supplied Cockpit Quadlet can be activated.
8. A later image update can be applied with bootc and rolled back.

See [docs/VM-TEST.md](docs/VM-TEST.md).

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
