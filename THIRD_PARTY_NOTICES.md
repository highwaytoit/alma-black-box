# Third-party notices

## Realtek USB Ethernet udev rule

`system_files/usr/lib/udev/rules.d/50-usb-realtek-net.rules` is carried from the Universal Blue `ublue-os/packages` project, which tracks the rule source from `bb-qq/r8152`.

Sources:

- https://github.com/ublue-os/packages/blob/main/packages/ublue-os-udev-rules/src/udev-rules.d/50-usb-realtek-net.rules
- https://github.com/bb-qq/r8152

Keep this attribution with the copied rule and review upstream changes before updating it.

## UPSide

UPSide is built from its upstream tagged source and pinned commit:

- https://github.com/deviationist/cockpit-upside

The build dependencies are used only in a separate build stage and are not copied into the final operating-system image.
