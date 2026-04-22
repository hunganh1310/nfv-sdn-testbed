# ADR-002: Three-Plane Network Segmentation

- **Status:** Accepted
- **Date:** $(date +%Y-%m-%d)
- **Deciders:** Platform Engineering
- **Supersedes:** —
- **Related:** ADR-001 (Git Flow)

## Context

The NFV/SDN testbed must carry three fundamentally different traffic types:
orchestration/management, east-west tenant data, and north-south external
egress. Mixing these on a single flat network creates security, performance,
and troubleshooting problems, and does not reflect how real Telco/Cloud
production deployments are built.

## Decision

Adopt a **three-plane model** with VLAN-tagged isolation:

| Plane       | VLAN | CIDR              | Isolation           |
|-------------|------|-------------------|---------------------|
| Management  | 10   | `10.10.10.0/24`   | NAT + host-only SSH |
| Data/Tenant | 20   | `10.10.20.0/24`   | Isolated bridge     |
| External    | 30   | `10.10.30.0/24`   | NAT to upstream     |

Each node (Node-0/1/2) receives **three vNICs**, one per plane, with
statically assigned addresses.

## Consequences

**Positive**
- Matches ETSI NFV-INF and OpenStack reference architectures
- Enables realistic VXLAN overlay testing (Phase 5)
- Security boundaries map cleanly to firewall rules
- Troubleshooting is simpler — traffic type is obvious from interface

**Negative**
- Higher libvirt config complexity (3 bridges vs 1)
- Slightly more RAM overhead per VM (3 NICs)
- Requires VLAN-aware bridges — must verify libvirt/OVS support early

**Mitigations**
- Automate bridge creation via Ansible (Phase 2 step 7)
- Document exact `virsh net-define` XML in runbook 02

## Alternatives Considered

1. **Single flat network** — rejected: unrealistic, insecure
2. **Two planes (mgmt + data)** — rejected: no clear path for floating IPs
3. **Full OVS underlay from day 1** — rejected: too much complexity before learning basics; we'll migrate to OVS in Phase 5
