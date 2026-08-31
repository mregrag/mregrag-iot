#!/bin/bash

set -e

CLUSTER_NAME="iot-cluster"

echo "==> Installing required packages..."

sudo pacman -Syu --needed --noconfirm \
    docker \
    kubectl \
    git \
    curl

echo "==> Enabling Docker..."

sudo systemctl enable --now docker.service

echo "==> Adding current user to docker group..."

sudo usermod -aG docker "$USER"

echo "==> Installing K3d..."

if ! command -v k3d >/dev/null 2>&1; then
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
fi

echo "==> Creating K3d cluster..."

if ! k3d cluster list | grep -q "^${CLUSTER_NAME} "; then
    k3d cluster create "$CLUSTER_NAME" \
        --servers 1 \
        --agents 1 \
        -p "8888:30080@agent:0"
fi

echo "==> Checking cluster..."

kubectl get nodes

echo
echo "==> Done."
echo
echo "Log out/in or run:"
echo "    newgrp docker"
