#!/bin/bash

set -e

CLUSTER_NAME="iot-cluster"

echo "==> Checking required tools..."

# Install Docker if it is not installed.
if ! command -v docker >/dev/null 2>&1; then
    echo "==> Installing Docker..."
    sudo pacman -S --needed --noconfirm docker
fi

# Install kubectl if it is not installed.
if ! command -v kubectl >/dev/null 2>&1; then
    echo "==> Installing kubectl..."
    sudo pacman -S --needed --noconfirm kubectl
fi

# Install Git if it is not installed.
if ! command -v git >/dev/null 2>&1; then
    echo "==> Installing Git..."
    sudo pacman -S --needed --noconfirm git
fi

# Install curl if it is not installed.
if ! command -v curl >/dev/null 2>&1; then
    echo "==> Installing curl..."
    sudo pacman -S --needed --noconfirm curl
fi

# Install K3d if it is not installed.
if ! command -v k3d >/dev/null 2>&1; then
    echo "==> Installing K3d..."
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
fi

echo "==> Configuring Docker..."

sudo systemctl enable --now docker.service

# Add the current user to the docker group if necessary.
if ! id -nG "$USER" | grep -qw docker; then
    sudo usermod -aG docker "$USER"
    echo "==> Added $USER to the docker group."
    echo "==> Run 'newgrp docker' before using Docker without sudo."
fi

echo "==> Checking K3d cluster..."

if ! k3d cluster list | grep -q "^${CLUSTER_NAME} "; then
    echo "==> Creating K3d cluster..."

    k3d cluster create "$CLUSTER_NAME" \
        --servers 1 \
        --agents 1 \
        -p "8888:30080@agent:0"
else
    echo "==> K3d cluster '$CLUSTER_NAME' already exists."
fi

echo
echo "==> Checking Kubernetes nodes..."
kubectl get nodes

echo
echo "==> Installation completed successfully."
