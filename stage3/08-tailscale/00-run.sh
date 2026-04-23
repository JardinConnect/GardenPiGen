#!/bin/bash -e

# Download Tailscale GPG key directly into the rootfs (outside chroot)
curl -fsSL https://pkgs.tailscale.com/stable/debian/bookworm.noarmor.gpg \
    -o "${ROOTFS_DIR}/usr/share/keyrings/tailscale-archive-keyring.gpg"

# Install the apt sources file
install -m 644 files/tailscale.sources "${ROOTFS_DIR}/etc/apt/sources.list.d/"

# Update apt so the package is available for 00-packages install
on_chroot << EOF
apt-get update
EOF
