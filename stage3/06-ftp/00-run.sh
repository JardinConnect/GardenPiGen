#!/bin/bash -e

# Deploy vsftpd configuration
install -m 644 files/vsftpd.conf "${ROOTFS_DIR}/etc/vsftpd.conf"

on_chroot << EOF
# Create the ftp admin user
useradd -m -s /bin/bash admin || true
echo "admin:admin" | chpasswd

# Enable vsftpd to start at boot
systemctl enable vsftpd
EOF
