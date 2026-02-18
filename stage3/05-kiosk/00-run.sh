#!/bin/bash -e

install -m 644 files/kiosk.service "${ROOTFS_DIR}/etc/systemd/system/"

install -m 755 files/kiosk.sh "${ROOTFS_DIR}/usr/local/bin/"

mkdir -p "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/autostart"

on_chroot << EOF
# Enable kiosk service
systemctl enable kiosk.service
EOF
