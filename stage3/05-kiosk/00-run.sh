#!/bin/bash -e

install -m 644 files/kiosk.service "${ROOTFS_DIR}/etc/systemd/system/"

install -m 755 files/kiosk.sh "${ROOTFS_DIR}/usr/local/bin/"

mkdir -p "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/autostart"

mkdir -p "${ROOTFS_DIR}/etc/systemd/system/graphical.target.wants"
ln -sf ../kiosk.service "${ROOTFS_DIR}/etc/systemd/system/graphical.target.wants/kiosk.service"

mkdir -p "${ROOTFS_DIR}/var/lib/systemd/linger"
touch "${ROOTFS_DIR}/var/lib/systemd/linger/${FIRST_USER_NAME}"

mkdir -p "${ROOTFS_DIR}/etc/systemd/system/getty@tty1.service.d"
cat > "${ROOTFS_DIR}/etc/systemd/system/getty@tty1.service.d/autologin.conf" << AUTOLOGIN
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin ${FIRST_USER_NAME} --noclear %I \$TERM
AUTOLOGIN
