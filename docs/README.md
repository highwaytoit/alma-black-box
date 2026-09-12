# Pasiv Black Box local operator guide

This directory is installed in every Pasiv Black Box image at `/usr/share/pasiv-black-box/doc/`.

Pasiv Black Box is a purpose-built bootc appliance. Host-level administration, UPS/power integration, networking, and hardware diagnostics are native. Replaceable monitoring applications are expected to run as Podman Quadlets.

Useful locations:

- Local documentation: `/usr/share/pasiv-black-box/doc/`
- Supplied Quadlet templates: `/usr/share/pasiv-black-box/quadlets/`
- Active system Quadlets: `/etc/containers/systemd/`
- NUT configuration: `/etc/ups/` or the paths provided by the installed NUT packages
- Cockpit/UPSide assets: `/usr/share/cockpit/`
- Image trust policy: `/etc/containers/policy.json`

Nothing in the supplied Quadlet template library is active merely because the image contains it.

The recommended deployment model is to copy the desired template into `/etc/containers/systemd/`, customize the local copy, and leave the image-supplied template untouched.

## Documentation index

- [Quadlet deployment guidance](QUADLETS.md)
- [Quadlet library index](QUADLET-LIBRARY.md)
- [NUT and UPSide integration](NUT-UPSide.md)
