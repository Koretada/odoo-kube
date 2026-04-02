#!/bin/bash
set -e

CLUSTER_NAME="odoo-ha"

if ! command -v helm &> /dev/null; then
    echo "L'outil 'helm' n'est pas installé."
    exit 1
fi

echo "Création du cluster kind '$CLUSTER_NAME'..."
kind create cluster --name $CLUSTER_NAME --config kind-config.yaml

echo "Ajout du repository Helm de Traefik..."
helm repo add traefik https://traefik.github.io/charts
helm repo update

echo "Installation de Traefik avec support de la Gateway API..."
helm install traefik traefik/traefik \
  --namespace traefik-system \
  --create-namespace \
  --set ports.web.nodePort=30080 \
  --set ports.websecure.nodePort=30443 \
  --set providers.kubernetesGateway.enabled=true \
  --wait

echo "Cluster prêt ! La Gateway API et Traefik sont opérationnels."
