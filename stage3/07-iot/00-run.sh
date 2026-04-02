#!/bin/bash -e

IOT_SUBMODULE_PATH="${BASE_DIR}/iot/iot-pi5"
IOT_INSTALL_PATH="${ROOTFS_DIR}/opt/garden-iot-pi5"

if [ ! -d "${IOT_SUBMODULE_PATH}" ] || [ -z "$(ls -A "${IOT_SUBMODULE_PATH}")" ]; then
	echo "ERROR: iot-pi5 module not initialized!"
	echo "Please run: git submodule update --init --recursive"
	exit 1
fi

mkdir -p "${ROOTFS_DIR}/var/"
mkdir -p "${IOT_INSTALL_PATH}"

cp -a "${IOT_SUBMODULE_PATH}/." "${IOT_INSTALL_PATH}/"

install -m 644 files/garden_iot_pi5.service "${ROOTFS_DIR}/etc/systemd/system/"

on_chroot << EOF
cd /opt/garden-iot-pi5

python3 -m venv venv
source venv/bin/activate

pip3 install -r requirements.txt

chown -R root:root /opt/garden-iot-pi5
chmod -R u=rwX,go=rX /opt/garden-iot-pi5

systemctl enable garden_iot_pi5.service
EOF