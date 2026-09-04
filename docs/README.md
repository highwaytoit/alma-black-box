# Alma Black Box local operator guide

This directory is installed in every Alma Black Box image at `/usr/share/alma-black-box/doc/`.

Alma Black Box is a purpose-built bootc appliance. Host-level administration, UPS/power integration, networking, and hardware diagnostics are native. Replaceable monitoring applications are expected to run as Podman Quadlets.

Useful locations:

- Local documentation: `/usr/share/alma-black-box/doc/`
- Supplied Quadlet templates: `/usr/share/alma-black-box/quadlets/`
- Active system Quadlets: `/etc/containers/systemd/`
- NUT configuration: `/etc/ups/` or the paths provided by the installed NUT packages
- Cockpit/UPSide assets: `/usr/share/cockpit/`
- Image trust policy: `/etc/containers/policy.json`

Nothing in the supplied Quadlet template library is active merely because the image contains it.

The recommended deployment model is to copy the desired template into `/etc/containers/systemd/`, customize the local copy, and leave the image-supplied template untouched. Symlinking directly to a supplied template is possible but means future image updates can change the active service definition.

See `QUADLETS.md` for Quadlet deployment guidance and `NUT-UPSide.md` for UPS integration notes.
