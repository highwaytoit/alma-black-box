#!/usr/bin/bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${repo_root}"

bash -n build_files/build.sh
bash -n build_files/install-image-trust.sh
bash -n build_files/software.env

python3 - <<'PY2'
from pathlib import Path
import yaml

with Path('.github/workflows/build.yml').open() as f:
    yaml.safe_load(f)

required = [
    'Containerfile',
    'README.md',
    'cosign.pub',
    'almalinux-bootc.pub',
    'quadlets/cockpit.container',
    'system_files/usr/lib/udev/rules.d/50-usb-realtek-net.rules',
]
for path in required:
    if not Path(path).is_file():
        raise SystemExit(f'missing required file: {path}')
PY2

grep -q '@@COCKPIT_WS_IMAGE@@' quadlets/cockpit.container
grep -q 'BEGIN PUBLIC KEY' cosign.pub
grep -q 'BEGIN PUBLIC KEY' almalinux-bootc.pub

echo "Static repository validation passed."
