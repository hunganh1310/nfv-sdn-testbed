#!/bin/bash
echo "Waiting for k3s API to come online..."
until kubectl get namespace monitoring >/dev/null 2>&1; do
    sleep 2
    echo -n "."
done

echo "API is up! Force deleting monitoring namespace before it crashes the node..."
kubectl delete namespace monitoring --force --grace-period=0
kubectl delete clusterrolebindings,clusterroles,validatingwebhookconfigurations,mutatingwebhookconfigurations -l app.kubernetes.io/instance=monitoring || true

echo "Done! The host RAM should be stable now."
