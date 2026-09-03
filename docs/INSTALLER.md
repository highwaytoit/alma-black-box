# Alma Black Box installer ISO

Alma Black Box uses the published bootc image as the operating-system source of truth. The installer ISO is disposable bootstrap media generated separately from the production image.

The recommended builder is the **Alma Black Box ISO Builder** template:

https://github.com/highwaytoit/alma-black-box-iso

The ISO uses the `bootc-installer` image type. A dedicated AlmaLinux bootc installer container supplies Anaconda and Lorax only for ISO construction; those installer packages are not added to the production Alma Black Box image. The selected bootc image is supplied separately as the installer payload.

## Build policy

The ISO builder is intentionally manual-only.

Use the template repository, click **Use this template**, create a repository in your own GitHub account, then run **Build Alma Black Box installer ISO** from GitHub Actions whenever you need fresh installation media.

The default image is:

```text
ghcr.io/highwaytoit/alma-black-box:10
```

Every run resolves that moving tag to its current amd64 digest before building, so a template copy created months earlier still installs the image currently published behind `:10`.

The default image is verified with the supplied Cosign public key. The template also allows an advanced user to select another public bootc image and, when intentionally required, disable the default signature check.

Generated GitHub Actions artifacts are retained for only one day. The template is an ISO builder, not a long-term ISO archive.

## Destructive installation model

The installer is unattended and destructive. Its Kickstart contains `clearpart --all`.

> [!CAUTION]
> **Disconnect every disk except the intended installation disk before booting this ISO on physical hardware.**

Use it only when the machine exposes one intended installation disk:

- VM validation: attach one blank virtual disk.
- Lenovo Black Box: physically disconnect the 240 GB data SSD before installation and leave only the 128 GB OS SSD attached.

Do not boot this installer with disks attached whose contents must be preserved.

## Firmware and partition layout

The default installer targets x86_64 UEFI systems.

The target disk layout is:

```text
GPT
├─ 512 MiB  EFI System Partition  /boot/efi
├─   1 GiB  XFS                    /boot
└─ remainder XFS                   /
```

The root partition has an 8 GiB minimum and grows to consume the remaining disk space. No swap partition is created.

The partitioning, hostname, timezone, networking, and initial account are defined in the template repository at:

```text
installer/iso.toml
```

Edit that file in your template-derived repository before starting the workflow if a different layout is required.

## Initial account

The default installer locks direct root login and creates one temporary administrator:

```text
username: bbox
password: bbox
groups:   wheel
```

The repository stores a one-way hash rather than a real private password. The public `bbox` credential is intentionally only a first-login bootstrap credential.

Immediately after first boot, log in as `bbox` and run:

```bash
passwd
```

Enter `bbox` as the current password and then set your new private password.

Do not place a real personal password in a public template repository. Do not expose administrative services before changing the temporary password on a real machine.

## Building and downloading the ISO

In your repository created from the ISO Builder template:

1. Open **Actions**.
2. Select **Build Alma Black Box installer ISO**.
3. Click **Run workflow**.
4. Leave the default image unchanged unless you deliberately want a different bootc payload.
5. Wait for the workflow to finish.
6. Open the completed run and use the **Download installer artifact** link in the Summary.
7. Extract `alma-black-box-installer`.

The artifact contains:

```text
alma-black-box-installer.iso
SHA256SUMS
```

The artifact expires after one day. Run the workflow again if fresh media is needed later.

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

Then continue with `docs/VM-TEST.md` to validate native tools, Cockpit Quadlet behavior, reboot, bootc upgrade, and rollback.

## Bare-metal installation

Only after VM validation:

1. Shut down the Lenovo.
2. Disconnect the 240 GB data SSD.
3. Leave only the intended 128 GB OS SSD attached.
4. Boot the validated installer ISO in UEFI mode.
5. Let the unattended installation complete and reboot.
6. Log in locally as `bbox` / `bbox` and immediately change the password with `passwd`.
7. Verify the disk layout and `bootc status`.
8. Shut down the machine.
9. Reconnect the 240 GB SSD.
10. Boot again and configure that disk separately as application/monitoring data storage.

## Updates after installation

The ISO is not the update mechanism. Once installed, the machine follows the normal Alma Black Box bootc image:

```text
ghcr.io/highwaytoit/alma-black-box:10
```

Future operating-system changes arrive through bootc. Build another ISO only when fresh bootstrap media is needed.
