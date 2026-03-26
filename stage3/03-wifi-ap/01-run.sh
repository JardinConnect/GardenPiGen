#!/bin/bash -e

# Load AP configuration
source files/ap-config

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
interface=wlan0
dhcp-range=192.168.4.2,192.168.4.20,255.255.255.0,24h
domain=wlan
address=/gardenpi.local/192.168.4.1
EOF

# Configure NetworkManager to ignore wlan0 (hostapd will manage it)
mkdir -p "${ROOTFS_DIR}/etc/NetworkManager/conf.d"
cat > "${ROOTFS_DIR}/etc/NetworkManager/conf.d/unmanaged-wlan0.conf" << EOF
[keyfile]
unmanaged-devices=interface-name:${AP_INTERFACE}
EOF

# Create static IP configuration for wlan0 using ifupdown
mkdir -p "${ROOTFS_DIR}/etc/network/interfaces.d"
cat > "${ROOTFS_DIR}/etc/network/interfaces.d/${AP_INTERFACE}" << EOF
allow-hotplug ${AP_INTERFACE}
iface ${AP_INTERFACE} inet static
    address ${AP_IP_ADDRESS}
    netmask ${AP_NETMASK}
    network ${AP_NETWORK}
    broadcast ${AP_BROADCAST}
EOF

echo "net.ipv4.ip_forward=1" >> "${ROOTFS_DIR}/etc/sysctl.conf"

install -m 644 files/garden-ap.service "${ROOTFS_DIR}/etc/systemd/system/garden-ap.service"

on_chroot << EOF
systemctl unmask hostapd
systemctl enable hostapd
systemctl enable dnsmasq
systemctl enable garden-ap.service
EOF
