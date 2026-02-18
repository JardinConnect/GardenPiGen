#!/bin/bash -e

# Install systemd service for kiosk
install -m 644 files/kiosk.service "${ROOTFS_DIR}/etc/systemd/system/"

# Install kiosk script
install -m 755 files/kiosk.sh "${ROOTFS_DIR}/usr/local/bin/"

# Create kiosk config directory
mkdir -p "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/autostart"

on_chroot << EOF
# Enable kiosk service
systemctl enable kiosk.service

# Disable screen blanking and power management
cat >> /etc/xdg/lxsession/LXDE-pi/autostart << 'AUTOSTART'
@xset s off
@xset -dpms
@xset s noblank
AUTOSTART
EOF
