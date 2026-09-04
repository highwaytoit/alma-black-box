# NUT and UPSide

NUT and UPSide are installed natively because UPS monitoring, host shutdown, USB device access, and power-state handling belong to the host operating system.

The generic image deliberately does not contain:

- UPS model or USB identifiers
- NUT usernames/passwords
- `ups.conf` hardware configuration
- shutdown thresholds or timers
- Wake-on-LAN targets
- site-specific notification or recovery policy

Those settings are deployment-specific and should be configured by the administrator after installation.

UPSide is built in a separate build stage and copied into `/usr/share/cockpit/upside/`. Build dependencies such as Node.js and npm do not remain in the final image.

A typical deployment can use Alma Black Box as a NUT server for a directly attached UPS, with other systems connecting as NUT clients over the network.

Do not bake hardware-specific NUT configuration into the generic image.
