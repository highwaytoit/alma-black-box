#!/usr/bin/bash
set -ouex pipefail

: "${IMAGE_REPOSITORY:?IMAGE_REPOSITORY must be set by the image build}"
source /ctx/build_files/software.env
: "${ALMA_BLACK_BOX_PACKAGES:?ALMA_BLACK_BOX_PACKAGES must be set}"
: "${TAILSCALE_PACKAGE:?TAILSCALE_PACKAGE must be set}"
: "${NETBIRD_PACKAGE:?NETBIRD_PACKAGE must be set}"
: "${COCKPIT_WS_IMAGE:?COCKPIT_WS_IMAGE must be set}"

# Declarative host configuration first.
cp -avf /ctx/system_files/. /

# AlmaLinux 10.1+ enables CRB by default. EPEL software on EL10 expects the
# CRB SELinux policy split to be available, so fail clearly if the upstream
# base ever changes that contract rather than silently composing a broken image.
if ! dnf repolist --enabled | grep -Eiq '(^|[[:space:]])crb([[:space:]]|$)'; then
    echo "ERROR: AlmaLinux CRB repository is not enabled in the upstream bootc image."
    exit 1
fi

# EPEL provides several lightweight host tools used by this image, including
# NUT, btop, and micro.
dnf install -y epel-release curl

# Official third-party repositories.
curl -fsSL \
    https://pkgs.tailscale.com/stable/rhel/10/tailscale.repo \
    -o /etc/yum.repos.d/tailscale.repo

cat > /etc/yum.repos.d/netbird.repo <<'REPO'
[netbird]
name=netbird
baseurl=https://pkgs.netbird.io/yum/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.netbird.io/yum/repodata/repomd.xml.key
repo_gpgcheck=1
REPO

read -r -a native_packages <<< "${ALMA_BLACK_BOX_PACKAGES}"
dnf install -y "${native_packages[@]}"

# Tailscale is available but remains unconfigured and disabled in the generic image.
dnf install -y "${TAILSCALE_PACKAGE}"
systemctl disable tailscaled.service 2>/dev/null || true

# NetBird's RPM scriptlets try to start/configure the service. Install the RPM
# payload without scriptlets during image composition; runtime enrollment is an
# explicit administrator action.
dnf --setopt=tsflags=noscripts install -y "${NETBIRD_PACKAGE}"
systemctl disable netbird.service 2>/dev/null || true

# NUT configuration is hardware/site specific and is never enabled by the image.
for unit in nut-server.service nut-monitor.service nut-driver@.service; do
    systemctl disable "${unit}" 2>/dev/null || true
done

# The web-facing Cockpit service is intentionally a Quadlet. Keep native ws
# socket/service disabled if a future dependency ever happens to pull it in.
systemctl disable cockpit.socket cockpit.service 2>/dev/null || true

# Install image signature trust for future bootc updates from this repository.
/ctx/build_files/install-image-trust.sh "${IMAGE_REPOSITORY}"

# Ship local operator documentation and inactive Quadlet templates.
install -d -m0755 /usr/share/doc/alma-black-box
cp -avf /ctx/docs/. /usr/share/doc/alma-black-box/

install -d -m0755 /usr/share/alma-black-box/quadlets
cp -avf /ctx/quadlets/. /usr/share/alma-black-box/quadlets/
sed -i "s|@@COCKPIT_WS_IMAGE@@|${COCKPIT_WS_IMAGE}|g" \
    /usr/share/alma-black-box/quadlets/cockpit.container

# Build-time validation. If a declared host capability disappears, fail the image.
for cmd in \
    bootc podman nmcli firewall-cmd sshd \
    upsc nut-scanner \
    tailscale netbird \
    fwupdmgr smartctl sensors nvme lsusb lspci ethtool powertop \
    btop micro tmux jq rsync tcpdump dig traceroute nc iperf3 semanage \
    cockpit-bridge; do
    command -v "${cmd}"
done

rpm -q selinux-policy-extra cockpit-system cockpit-podman cockpit-storaged

test -f /usr/share/cockpit/upside/manifest.json
test -f /usr/share/alma-black-box/quadlets/cockpit.container
test -f /usr/share/doc/alma-black-box/README.md
! grep -q '@@COCKPIT_WS_IMAGE@@' /usr/share/alma-black-box/quadlets/cockpit.container

# Services which define the host itself remain available. Remote-access clients,
# UPS behavior, Cockpit web service, and monitoring applications require explicit
# administrator activation/configuration.
systemctl enable NetworkManager.service 2>/dev/null || true
systemctl enable firewalld.service 2>/dev/null || true
systemctl enable sshd.service 2>/dev/null || true

dnf clean all
rm -rf /var/cache/dnf/*
