#!/bin/bash -e

# Install hostapd configuration
install -m 644 files/hostapd.conf "${ROOTFS_DIR}/etc/hostapd/hostapd.conf"

# Configure hostapd service to use our config
cat > "${ROOTFS_DIR}/etc/default/hostapd" << EOF
DAEMON_CONF="/etc/hostapd/hostapd.conf"
EOF

# Install dnsmasq configuration
install -m 644 files/dnsmasq.conf "${ROOTFS_DIR}/etc/dnsmasq.d/gardenconnect.conf"

# Prevent dnsmasq from binding to all interfaces
cat > "${ROOTFS_DIR}/etc/dnsmasq.conf" << EOF
# Only bind to wlan0
bind-interfaces
EOF

# Configure NetworkManager to ignore wlan0
mkdir -p "${ROOTFS_DIR}/etc/NetworkManager/conf.d"
cat > "${ROOTFS_DIR}/etc/NetworkManager/conf.d/unmanaged-wlan0.conf" << EOF
[keyfile]
unmanaged-devices=interface-name:wlan0
EOF

# Create static IP configuration for wlan0
mkdir -p "${ROOTFS_DIR}/etc/network/interfaces.d"
cat > "${ROOTFS_DIR}/etc/network/interfaces.d/wlan0" << EOF
allow-hotplug wlan0
iface wlan0 inet static
    address 192.168.4.1
    netmask 255.255.255.0
    network 192.168.4.0
    broadcast 192.168.4.255
EOF

# Enable IP forwarding
echo "net.ipv4.ip_forward=1" >> "${ROOTFS_DIR}/etc/sysctl.conf"

# Install systemd service for NAT
install -m 644 files/garden-ap.service "${ROOTFS_DIR}/etc/systemd/system/garden-ap.service"

# Enable the access point services
on_chroot << EOF
systemctl unmask hostapd
systemctl enable hostapd
systemctl enable dnsmasq
systemctl enable garden-ap.service
EOF
