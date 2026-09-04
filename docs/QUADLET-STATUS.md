# Quadlet validation status

This file tracks the Alma Black Box supplied Quadlet library.

A template should not be treated as project-approved merely because it exists in the repository. The intended lifecycle is:

1. Planned
2. Drafted
3. Deployed on an Alma Black Box test VM or bare-metal test node
4. Tested for configuration, SELinux, networking, storage, restart behavior, and reboot persistence as applicable
5. Approved and shipped as a supported template
6. Revalidated when an upstream change requires it

The recommended deployment model for users is to copy a supplied template from `/usr/share/alma-black-box/quadlets/` into `/etc/containers/systemd/` and customize the local copy. Symlink deployment is possible but not recommended. See `QUADLETS.md`.

## Current and planned templates

| Component | Purpose | Status | Notes |
| --- | --- | --- | --- |
| Cockpit web service | Browser-facing Cockpit service for the native host bridge/pages | Supplied; validation status to be confirmed | Existing v1 template |
| Grafana | Dashboards and visualization | Planned | Monitoring application; not baked into the OS |
| Prometheus | Metrics collection and querying | Planned | Candidate primary metrics collector |
| Loki | Log storage and querying | Planned | Intended for centralized log analysis |
| Grafana Alloy | Telemetry collection and forwarding | Planned | Candidate collector for logs/metrics/telemetry |
| VictoriaMetrics | Time-series metrics storage | Planned | Evaluate as an alternative or complementary metrics backend |
| Alertmanager | Alert grouping, silencing, and routing | Planned | Prometheus alerting companion |
| Blackbox Exporter | External HTTP/TCP/DNS/ICMP-style probing | Planned | Useful for monitoring services from the Alma Black Box failure domain |
| SNMP Exporter | Network-device metrics via SNMP | Planned | Candidate for MikroTik and future managed network devices |
| Node Exporter | Linux host metrics | Planned | Candidate for host-level CPU, memory, filesystem, and network metrics |
| NUT Exporter | Expose UPS/NUT telemetry as metrics | Planned | NUT itself remains native on the host |
| Uptime Kuma | Simple service reachability and notification monitoring | Planned | Complements metrics-oriented monitoring |
| OpenClaw | Read-only conversational incident-triage helper | Planned | Intended as an optional layer above monitoring data, not an autonomous administrator |
| n8n | Workflow/automation candidate | Experimental candidate | Compare against Windmill before deciding whether it belongs permanently |
| Windmill | Workflow/automation candidate | Experimental candidate | Compare against n8n before deciding whether it belongs permanently |

## Validation record

When a template is tested, record at minimum:

- component and template name
- upstream container image and tested version/tag/digest
- Alma Black Box image version
- test date
- test platform: VM or bare metal
- required ports
- persistent storage paths
- required configuration files or secrets
- SELinux requirements
- container privileges/capabilities
- start/restart behavior
- reboot persistence
- known limitations
- final status: tested, approved, needs changes, or rejected

Do not add a template to the approved library until it has been exercised on the Alma Black Box test environment.
