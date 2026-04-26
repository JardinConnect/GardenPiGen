#!/bin/bash -e

# Disable and mask hostapd to ensure AP mode is off
on_chroot << EOF
systemctl disable hostapd 2>/dev/null || true
systemctl mask hostapd 2>/dev/null || true
EOF

# Ensure wlan0 is fully managed by NetworkManager (override any unmanaged-devices rules)
mkdir -p "${ROOTFS_DIR}/etc/NetworkManager/conf.d"
cat > "${ROOTFS_DIR}/etc/NetworkManager/conf.d/99-wlan-managed.conf" << 'EOF'
[keyfile]
unmanaged-devices=none

[device]
wifi.scan-rand-mac-address=no
EOF

# Re-enable wireless in the NetworkManager persistent state if it was blocked
NM_STATE="${ROOTFS_DIR}/var/lib/NetworkManager/NetworkManager.state"
if [ -f "${NM_STATE}" ]; then
    sed -i 's/WirelessEnabled=false/WirelessEnabled=true/' "${NM_STATE}"
else
    mkdir -p "${ROOTFS_DIR}/var/lib/NetworkManager"
    cat > "${NM_STATE}" << 'EOF'
[main]
WirelessEnabled=true
WWANEnabled=true
EOF
fi

# Create a NetworkManager connection profile for wlan0 as the default managed interface.
# route-metric=100 ensures wlan0 is preferred as the default route over other interfaces.
mkdir -p "${ROOTFS_DIR}/etc/NetworkManager/system-connections"
cat > "${ROOTFS_DIR}/etc/NetworkManager/system-connections/wlan0-managed.nmconnection" << 'EOF'
[connection]
id=wlan0-managed
type=wifi
interface-name=wlan0
autoconnect=false

[wifi]
mode=infrastructure

[ipv4]
method=auto
route-metric=100

[ipv6]
method=auto
route-metric=100
EOF

chmod 600 "${ROOTFS_DIR}/etc/NetworkManager/system-connections/wlan0-managed.nmconnection"
