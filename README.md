# 5G NFV/SDN Testbed

A comprehensive 5G End-to-End Telco Cloud testbed based on Network Function Virtualization (NFV) and Software-Defined Networking (SDN) concepts. This repository provides Infrastructure-as-Code (IaC) to automatically provision, deploy, and manage a containerized 5G environment.

## 🌟 Overview

This testbed simulates a modern 5G telecommunications network using open-source components deployed on a Kubernetes cluster. It bridges 5G core operations with an SDN-controlled data plane to provide a realistic, research-grade environment.

### Key Components

*   **5G Core Network**: [Open5GS](https://open5gs.org/)
*   **5G RAN Simulation**: [UERANSIM](https://github.com/aligungr/UERANSIM)
*   **SDN Controller**: [ONOS](https://opennetworking.org/onos/) (Open Network Operating System)
*   **SDN Data Plane**: Open vSwitch (OVS) integrated into Kubernetes via Multus CNI
*   **Container Orchestration**: Kubernetes (K3s/kubeadm)
*   **Infrastructure Management**: Ansible & KVM/Libvirt

## 🏗️ Architecture

The testbed is deployed across multiple KVM virtual machines (node-0, node-1, node-2), abstracting the physical hardware.

1.  **Management Plane**: Ansible playbooks that provision the underlying VMs and orchestrate the Kubernetes deployment.
2.  **Control Plane**: Open5GS Control Plane functions (AMF, SMF, PCF, UDM, etc.) and the ONOS SDN controller.
3.  **Data Plane**: Open5GS User Plane Function (UPF) dynamically networking with the UERANSIM gNB through Open vSwitch (OVS).

## 📁 Repository Structure

*   `ansible/` - Playbooks and roles for infrastructure and platform deployment.
    *   `playbooks/setup-hypervisor.yml` - Sets up KVM host prerequisites.
    *   `playbooks/site.yml` - Provisions virtual networks and KVM VMs.
    *   `playbooks/k8s.yml` - Installs the Kubernetes cluster.
    *   `playbooks/sdn.yml` & `dataplane.yml` - Deploys ONOS and configures OVS.
    *   `playbooks/open5gs.yml` - Deploys the 5G Core.
    *   `playbooks/ueransim.yml` - Deploys the RAN emulator (gNB & UE).
*   `sdn/` - ONOS applications and OpenFlow rules for the data plane.
*   `monitoring/` - Configuration for the Prometheus/Grafana observability stack.
*   `docs/` - Architectural Decision Records (ADRs), runbooks, and diagrams.
*   `scripts/` - Helper scripts (e.g., building Helm charts).

## 🚀 Getting Started

### Prerequisites

*   A Linux host (Ubuntu/Debian recommended) with nested virtualization enabled or running directly on bare metal.
*   At least 50GB of free disk space and 16GB RAM.
*   `ansible` installed on the host machine.
*   `libvirt` and `qemu-kvm` packages.

### Deployment Instructions

1.  **Prepare the Hypervisor**:
    ```bash
    cd ansible/
    ansible-playbook playbooks/setup-hypervisor.yml --ask-become-pass
    ```

2.  **Provision Virtual Machines**:
    ```bash
    ansible-playbook playbooks/site.yml
    ```

3.  **Deploy Kubernetes**:
    ```bash
    ansible-playbook -i inventory/hosts.ini playbooks/k8s.yml
    ```

4.  **Deploy the 5G Stack & SDN**:
    Run the respective playbooks to install the testbed components:
    ```bash
    ansible-playbook -i inventory/hosts.ini playbooks/sdn.yml
    ansible-playbook -i inventory/hosts.ini playbooks/open5gs.yml
    ansible-playbook -i inventory/hosts.ini playbooks/ueransim.yml
    ```

## 🧪 Verification

After the testbed is deployed, you can verify the end-to-end data plane by checking the UE registration and pinging the external network from the UE pod.

1.  **Check Pod Status**:
    ```bash
    kubectl get pods -A
    ```

2.  **Verify UE Connection**:
    ```bash
    kubectl logs -n ueransim -l app.kubernetes.io/component=ues
    ```
    *Look for `PDU Session establishment is successful` and the creation of `uesimtun0`.*

3.  **Ping External Network**:
    ```bash
    kubectl exec -n ueransim deployment/ueransim-ue-ueransim-ues -- ping -I uesimtun0 -c 4 8.8.8.8
    ```

## 🧹 Cleanup

To destroy the testbed and clean up the KVM resources, run:

```bash
./cleanup.sh
# OR via Ansible
ansible-playbook playbooks/teardown-vms.yml
```

## 📄 License

This project is open-source. See the [LICENSE](LICENSE) file for more details.
