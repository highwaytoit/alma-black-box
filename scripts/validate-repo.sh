#!/usr/bin/bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${repo_root}"

bash -n build_files/build.sh
bash -n build_files/finalize-image.sh
bash -n build_files/install-image-trust.sh
bash -n build_files/software.env
bash -n build_files/validate/identity.sh

python3 - <<'PY2'
from pathlib import Path
import yaml

for workflow in (
    '.github/workflows/build.yml',
    '.github/workflows/build-testing.yml',
):
    with Path(workflow).open() as f:
        yaml.safe_load(f)

required = [
    'Containerfile',
    'README.md',
    'cosign.pub',
    'almalinux-bootc.pub',
    'quadlets/cockpit.container',
    'build_files/finalize-image.sh',
    'build_files/validate/identity.sh',
    'system_files/etc/hostname',
    'system_files/etc/NetworkManager/conf.d/90-systemd-resolved.conf',
    'system_files/usr/lib/tmpfiles.d/pasiv-black-box-resolved.conf',
    'system_files/etc/sudoers.d/90-pasiv-black-box-passwordless-wheel',
    'system_files/etc/profile.d/zz-pasiv-black-box-prompt.sh',
    'system_files/usr/lib/systemd/system/pasiv-black-box-update.service',
    'system_files/usr/lib/systemd/system/pasiv-black-box-update.timer',
    'system_files/usr/lib/udev/rules.d/50-usb-realtek-net.rules',
]
for path in required:
    if not Path(path).is_file():
        raise SystemExit(f'missing required file: {path}')

legacy_paths = [
    'system_files/usr/lib/tmpfiles.d/alma-black-box-resolved.conf',
    'system_files/etc/sudoers.d/90-alma-black-box-passwordless-wheel',
    'system_files/etc/profile.d/zz-alma-black-box-prompt.sh',
    'system_files/usr/lib/systemd/system/alma-black-box-update.service',
    'system_files/usr/lib/systemd/system/alma-black-box-update.timer',
]
for path in legacy_paths:
    if Path(path).exists():
        raise SystemExit(f'legacy Alma Black Box path remains: {path}')
PY2

grep -q '@@COCKPIT_WS_IMAGE@@' quadlets/cockpit.container
grep -q 'BEGIN PUBLIC KEY' cosign.pub
grep -q 'BEGIN PUBLIC KEY' almalinux-bootc.pub
grep -Fqx 'pasiv-black-box' system_files/etc/hostname
grep -Fqx 'dns=systemd-resolved' system_files/etc/NetworkManager/conf.d/90-systemd-resolved.conf
grep -Fqx 'L+ /etc/resolv.conf - - - - /run/systemd/resolve/stub-resolv.conf' \
    system_files/usr/lib/tmpfiles.d/pasiv-black-box-resolved.conf
grep -Fqx '%wheel ALL=(ALL) NOPASSWD: ALL' \
    system_files/etc/sudoers.d/90-pasiv-black-box-passwordless-wheel
grep -Fq 'ghcr.io/${{ github.repository_owner }}/pasiv-black-box' .github/workflows/build.yml
grep -Fq 'ghcr.io/${{ github.repository_owner }}/pasiv-black-box' .github/workflows/build-testing.yml
grep -Fq 'ARG IMAGE_REPOSITORY=ghcr.io/highwaytoit/pasiv-black-box' Containerfile
grep -Fq 'PASIV_BLACK_BOX_PACKAGES=' build_files/software.env

# The prompt shape/color is intentionally unchanged; only the product-specific
# filename/comment moved from Alma Black Box to Pasiv Black Box.
grep -Fqx "PS1='[\\[\\e[31m\\]\\u@\\h\\[\\e[0m\\] \\W]\\$ '" \
    system_files/etc/profile.d/zz-pasiv-black-box-prompt.sh

echo "Static repository validation passed."
