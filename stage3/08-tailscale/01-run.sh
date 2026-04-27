#!/bin/bash -e

install -m 755 files/configure-tailscale.sh "${ROOTFS_DIR}/usr/local/bin/"

on_chroot << EOF
systemctl enable tailscaled

# Configure Tailscale to accept routes and act as exit node
mkdir -p /etc/tailscale

# manually run on first boot: /usr/local/bin/configure-tailscale.sh
EOF
