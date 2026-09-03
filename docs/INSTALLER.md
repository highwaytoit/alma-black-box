# Alma Black Box installer ISO

Alma Black Box uses the published bootc image as the operating-system source of truth. The installer ISO is disposable bootstrap media generated from that image with osbuild's bootc image builder.

## Build policy

The installer workflow is separate from the normal operating-system image build.

It can be started manually from GitHub Actions and is also scheduled once per month. The workflow resolves `ghcr.io/highwaytoit/alma-black-box:10` to its current amd64 digest, verifies that exact digest with the repository Cosign public key, and builds the installer from the verified reference.

The installer workflow intentionally does not use `--use-librepo=True`.

## Destructive installation model

The installer is unattended and destructive. Its Kickstart contains `clearpart --all`.

Use it only when the machine exposes one intended installation disk:

- VM validation: attach one blank virtual disk.
- Lenovo Black Box: physically disconnect the 240 GB data SSD before installation and leave only the 128 GB OS SSD attached.

Do not boot this installer with disks attached whose contents must be preserved.

## Firmware and partition layout

The v1 installer targets UEFI systems.

The target disk layout is deliberately simple:

```text
GPT
├─ 512 MiB  EFI System Partition  /boot/efi
├─   1 GiB  XFS                    /boot
└─ remainder XFS                   /
```

A BIOS-GPT helper partition is not created because this installer targets UEFI. If legacy BIOS support is ever required, it should be added and tested as a separate installer change.

No disk swap partition is created.

## Initial account

The installer locks direct root login and creates one temporary administrator:

```text
username: bbox
password: bbox
groups:   wheel
```

This credential is intentionally simple for initial VM and console bootstrap. Change it immediately after the first boot:

```bash
passwd bbox
```

Do not activate Cockpit or expose administrative services before changing the temporary password on a real machine.

## Building the ISO

Open the repository's GitHub Actions page and run **Build Alma Black Box installer ISO**.

A successful run uploads an artifact named:

```text
alma-black-box-10-installer
```

The artifact contains:

```text
alma-black-box-10-installer.iso
SHA256SUMS
```

The ISO can be attached directly to a VM. After VM validation it can be written to a USB stick or booted through a suitable USB multiboot tool for bare-metal installation.

## VM-first acceptance test

Use UEFI firmware and one blank virtual disk. A 128 GB virtual disk best reproduces the intended physical installation.

After installation and first boot:

```bash
lsblk -f
findmnt / /boot /boot/efi
df -h / /boot /boot/efi
sudo bootc status
sudo systemctl --failed --no-pager
```

Confirm the partition sizes are approximately 512 MiB for the EFI System Partition, 1 GiB for `/boot`, and the remaining disk space for `/`.

Then continue with `docs/VM-TEST.md` to validate the native tools, Cockpit Quadlet, reboot behavior, a later `bootc upgrade`, and rollback.

## Bare-metal installation

Only after the VM installer and update/rollback flow are validated:

1. Shut down the Lenovo.
2. Disconnect the 240 GB data SSD.
3. Leave only the intended 128 GB OS SSD attached.
4. Boot the validated installer ISO in UEFI mode.
5. Let the unattended installation complete and reboot.
6. Log in locally as `bbox` / `bbox` and immediately change the password.
7. Verify the disk layout and `bootc status`.
8. Shut down the machine.
9. Reconnect the 240 GB SSD.
10. Boot again and configure that disk separately as application/monitoring data storage.

## Updates after installation

The ISO is not the update mechanism. Once installed, the machine follows the normal Alma Black Box bootc image:

```text
ghcr.io/highwaytoit/alma-black-box:10
```

Future operating-system changes arrive through bootc. The installer only needs occasional rebuilding so fresh bootstrap media is available.
