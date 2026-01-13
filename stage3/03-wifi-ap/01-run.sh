#!/bin/bash -e

# Install hostapd configuration
install -m 644 files/hostapd.conf "${ROOTFS_DIR}/etc/hostapd/hostapd.conf"

# Configure hostapd service to use our config
cat >> "${ROOTFS_DIR}/etc/default/hostapd" << EOF
DAEMON_CONF="/etc/hostapd/hostapd.conf"
EOF

# Install dnsmasq configuration
install -m 644 files/dnsmasq.conf "${ROOTFS_DIR}/etc/dnsmasq.d/gardenconnect.conf"

# Install network configuration script
install -m 755 files/setup-ap.sh "${ROOTFS_DIR}/usr/local/bin/setup-ap.sh"

# Install systemd service
install -m 644 files/garden-ap.service "${ROOTFS_DIR}/etc/systemd/system/garden-ap.service"

# Enable the access point service
on_chroot << EOF
systemctl unmask hostapd
systemctl enable hostapd
systemctl enable dnsmasq
systemctl enable garden-ap.service
EOF
