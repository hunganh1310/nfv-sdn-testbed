# Network Topology — NFV/SDN Testbed

> **Phase:** 2 — Network Architecture
> **Status:** Draft (design-only, no provisioning yet)
> **Owner:** Platform Engineering

---

## 1. Overview

The testbed uses a **three-plane network model** aligned with ETSI NFV-INF
recommendations and OpenStack reference architecture:

1. **Management Plane** — orchestration, SSH, API traffic
2. **Data Plane (Tenant)** — east-west VM traffic, VXLAN overlays
3. **External Plane (Provider)** — north-south, floating IPs, internet egress

Each plane is isolated by **VLAN tagging** on a shared virtual switch
inside WSL2/libvirt.

---

## 2. High-Level Topology
                ┌─────────────────────────────────┐
                │   WSL2 Ubuntu 22.04 (host)      │
                │   libvirt + KVM hypervisor      │
                │                                 │
                │   ┌───────────┐                 │
                │   │  virbr-mgmt (VLAN 10)       │
                │   │  10.10.10.0/24              │
                │   │  virbr-data (VLAN 20)       │
                │   │  10.10.20.0/24              │
                │   │  virbr-ext  (VLAN 30)       │
                │   │  10.10.30.0/24 — NAT out    │
                │   └───────────┘                 │
                │        │  │  │                  │
                │   ┌────┘  │  └────┐             │
                │   ▼       ▼       ▼             │
                │  Node-0  Node-1  Node-2         │
                │ (ctrl)  (cmpt)  (sdn+mon)       │
                └─────────────────────────────────┘

---

## 3. Node Role Matrix

| Node    | Role                        | Key Services                                                      | vCPU | RAM   | Disk  |
|---------|-----------------------------|-------------------------------------------------------------------|------|-------|-------|
| Node-0  | Controller + NFV Orchestrator | Keystone, Glance, Nova-API, Neutron-server, OSM (NBI/LCM/RO)    | 2    | 8 GB  | 40 GB |
| Node-1  | Compute + Network           | Nova-compute, Neutron L3/DHCP/Metadata agents, OVS, KVM nested   | 2    | 6 GB  | 40 GB |
| Node-2  | SDN + Monitoring            | ONOS, Prometheus, Grafana, Alertmanager, Suricata, Zeek          | 2    | 6 GB  | 30 GB |

> ⚠️ **Capacity note:** Total VM RAM (~20 GB) exceeds default WSL2 allocation.
> See ADR-003 (resource strategy) for mitigation: staggered bring-up + ballooning.

---

## 4. IP Addressing Plan

### 4.1 Physical / Virtual Subnets

| Plane        | CIDR              | VLAN | Gateway        | DHCP range           |
|--------------|-------------------|------|----------------|----------------------|
| Management   | `10.10.10.0/24`   | 10   | `10.10.10.1`   | `.100 – .200`        |
| Data/Tenant  | `10.10.20.0/24`   | 20   | `10.10.20.1`   | static only          |
| External     | `10.10.30.0/24`   | 30   | `10.10.30.1`   | `.100 – .200` (FIP)  |

### 4.2 Static Node Assignments

| Node   | Mgmt IP         | Data IP         | Ext IP          |
|--------|-----------------|-----------------|-----------------|
| Node-0 | `10.10.10.10`   | `10.10.20.10`   | `10.10.30.10`   |
| Node-1 | `10.10.10.11`   | `10.10.20.11`   | `10.10.30.11`   |
| Node-2 | `10.10.10.12`   | `10.10.20.12`   | `10.10.30.12`   |

### 4.3 Tenant Overlay Networks (inside VXLAN)

| Network        | CIDR              | Purpose                       |
|----------------|-------------------|-------------------------------|
| `tenant-net-a` | `192.168.10.0/24` | Example VNF chain network A   |
| `tenant-net-b` | `192.168.20.0/24` | Example VNF chain network B   |

---

## 5. Virtual Bridges (libvirt)

| Bridge        | Mode    | VLAN | Purpose                          |
|---------------|---------|------|----------------------------------|
| `virbr-mgmt`  | NAT     | 10   | Mgmt plane, host SSH reachable  |
| `virbr-data`  | Isolated| 20   | East-west only, no host route   |
| `virbr-ext`   | NAT     | 30   | Floating IPs, internet egress   |

---

## 6. Security Boundaries

- **Management plane** — SSH key-only, no passwords, firewalled to host subnet
- **Data plane** — no host routing; VMs can only reach each other on this bridge
- **External plane** — iptables SNAT to WSL2 eth0; no inbound except FIP NAT
- **Ansible vault** — all secrets encrypted; vault password never in Git

---

## 7. Diagrams

See:
- `docs/architecture/diagrams/network-topology.mmd` (Mermaid source)
- `docs/architecture/diagrams/network-topology.png` (rendered, to be added)

---

## 8. Open Questions / Future Work

- [ ] VLAN trunking inside libvirt — use `<vlan>` on `<interface>` or OVS bridge?
- [ ] External plane: use NAT or route via Windows host?
- [ ] IPv6 support — deferred to Phase 7
- [ ] MTU tuning for VXLAN (1450 vs 9000 jumbo) — benchmark in Phase 5

---

## 9. References

- ETSI GS NFV-INF 005 (Network Domain)
- OpenStack Networking Guide — https://docs.openstack.org/neutron/latest/
- OSM Reference Architecture — https://osm.etsi.org/docs/user-guide/
