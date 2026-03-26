#!/bin/bash -e

install -m 755 files/kiosk.sh "${ROOTFS_DIR}/usr/local/bin/"

cat > "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.bash_profile" << 'BASH_PROFILE'
if [ -z "${SSH_TTY}" ] && [ "$(tty)" = "/dev/tty1" ]; then
	if ! pgrep -u "${USER}" -x cage >/dev/null 2>&1; then
		exec /usr/local/bin/kiosk.sh
	fi
fi

if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi
BASH_PROFILE
chown 1000:1000 "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.bash_profile"
chmod 644 "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.bash_profile"

mkdir -p "${ROOTFS_DIR}/etc/systemd/system/getty@tty1.service.d"
cat > "${ROOTFS_DIR}/etc/systemd/system/getty@tty1.service.d/autologin.conf" << AUTOLOGIN
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin ${FIRST_USER_NAME} --noclear %I \$TERM
AUTOLOGIN
