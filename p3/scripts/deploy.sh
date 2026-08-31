#!/bin/bash

set -e

echo "Creating namespaces..."

kubectl apply -f "$(dirname "$0")/../confs/namespace.yaml"

echo "Installing Argo CD..."

kubectl apply \
    -n argocd \
    --server-side \
    --force-conflicts \
    -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "Waiting for Argo CD..."

kubectl wait \
    --namespace argocd \
    --for=condition=Available \
    deployment/argocd-server \
    --timeout=300s

echo "Creating Argo CD application..."

kubectl apply \
    -f "$(dirname "$0")/../confs/application.yaml"

echo
echo "======================================"
echo "Argo CD deployment completed."
echo "======================================"
echo

kubectl get ns
echo

kubectl get pods -n argocd
echo

kubectl get applications -n argocd
