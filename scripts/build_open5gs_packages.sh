#!/bin/bash
set -e

BASE_DIR="$(pwd)/vnf-packages/open5gs"
mkdir -p "$BASE_DIR/open5gs_knf" "$BASE_DIR/open5gs_ns"

# --- KNF Descriptor ---
cat << 'EOF' > "$BASE_DIR/open5gs_knf/open5gs_knf.yaml"
vnfd:
  id: open5gs_knf
  name: open5gs_knf
  description: "Open5GS Cloud Native Network Function (KNF)"
  mgmt-cp: mgmt-ext
  ext-cpd:
    - id: mgmt-ext
      int-cpd:
        cpd: mgmt-ext
        vdu-id: helm-vdu
  vdu:
    - id: helm-vdu
      name: helm-vdu
      int-cpd:
        - id: mgmt-ext
  kdu:
    - name: open5gs
      helm-chart: "open5gs/open5gs"
      helm-version: "v3"
  df:
    - id: default-df
EOF

# --- NS Descriptor ---
cat << 'EOF' > "$BASE_DIR/open5gs_ns/open5gs_ns.yaml"
nsd:
  nsd:
  - id: open5gs_ns
    name: open5gs_ns
    description: "Open5GS Network Service"
    version: '1.0'
    vnfd-id:
    - open5gs_knf
    df:
    - id: default-df
      vnf-profile:
      - id: '1'
        vnfd-id: open5gs_knf
        virtual-link-connectivity:
        - constituent-cpd-id:
          - constituent-base-element-id: '1'
            constituent-cpd-id: mgmt-ext
          virtual-link-profile-id: mgmtnet
      virtual-link-profile:
      - id: mgmtnet
        virtual-link-desc-id: mgmtnet
    virtual-link-desc:
    - id: mgmtnet
      mgmt-network: true
EOF

cd "$BASE_DIR"
tar -czf open5gs_knf.tar.gz open5gs_knf/
tar -czf open5gs_ns.tar.gz open5gs_ns/
echo "Open5GS OSM packages built successfully."
