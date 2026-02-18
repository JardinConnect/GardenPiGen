#!/bin/bash -e

# Remove the first-boot wizard that prompts for user creation
rm -f "${ROOTFS_DIR}/etc/xdg/autostart/piwiz.desktop"

# Create userconf file to indicate user is already configured
# This prevents the wizard from running
on_chroot << EOF
if [ ! -d /boot/firmware ]; then
    mkdir -p /boot/firmware
fi
EOF

echo "User garden is pre-configured" > "${ROOTFS_DIR}/boot/firmware/userconf.txt"
