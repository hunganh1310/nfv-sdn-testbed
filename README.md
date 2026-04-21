# 🌐 NFV/SDN Testbed — Cloud Engineering Lab

> **Status:** 🚧 Work in progress — full documentation will be added per phase.

A production-grade **NFV/SDN Testbed** integrating:

- **OSM** (NFV Orchestrator)
- **OpenStack** (Virtual Infrastructure Manager)
- **ONOS** (SDN Controller)
- **Open vSwitch + KVM** (Data plane & hypervisor)

## Repository Layout

| Path | Purpose |
|------|---------|
| `ansible/` | Configuration management (playbooks, roles, inventory) |
| `docs/` | Architecture diagrams, runbooks, ADRs |
| `sdn/` | ONOS apps and OpenFlow flow rules |
| `vnf-packages/` | OSM VNFD / NSD descriptors |
| `monitoring/` | Prometheus, Grafana, Suricata, Zeek configs |
| `scripts/` | Helper automation scripts |
| `terraform/` | (Future) infrastructure provisioning |

## Quick Links

- 📐 Architecture: `docs/architecture/`
- 📖 Runbooks: `docs/runbooks/`
- 🧾 Decisions: `docs/adr/`

