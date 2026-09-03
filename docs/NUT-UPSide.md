# NUT and UPSide

NUT and UPSide are installed natively because UPS monitoring, host shutdown, USB device access, and power-state handling belong to the host operating system.

The generic image deliberately does not contain:

- UPS model or USB identifiers
- NUT usernames/passwords
- `ups.conf` hardware configuration
- shutdown thresholds
- on-battery timers
- Wake-on-LAN target information

Those settings are deployment-specific.

UPSide is built in a separate build stage and copied into `/usr/share/cockpit/upside/`. Build dependencies such as Node.js and npm do not remain in the final image.

The intended physical deployment is:

```text
UPS USB -> Alma Black Box NUT server -> network NUT clients
```

For the home-server deployment, the eventual policy is expected to be: sustained on-battery state starts a timer on the protected server; after the configured delay the server shuts itself down cleanly. After mains power returns, the Black Box can later be configured to send Wake-on-LAN to the protected server.

Do not implement hardware-specific NUT configuration in the generic image.
