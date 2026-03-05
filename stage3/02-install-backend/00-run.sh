#!/bin/bash -e

FRONT_SUBMODULE_PATH="${BASE_DIR}/front/GardenFront"

mkdir -p "${ROOTFS_DIR}/var/www/gardenfront/web"

if [ -d "${FRONT_SUBMODULE_PATH}/build" ]; then
    cp -r "${FRONT_SUBMODULE_PATH}/build"/* "${ROOTFS_DIR}/var/www/gardenfront/web/"
fi

rm -rf "${ROOTFS_DIR}/var/www/html"
ln -s /var/www/gardenfront/web "${ROOTFS_DIR}/var/www/html"

install -m 644 files/garden_back.service "${ROOTFS_DIR}/etc/systemd/system/"

install -m 644 files/10-gardenback-proxy.conf "${ROOTFS_DIR}/etc/lighttpd/conf-available/"

install -m 644 files/mosquitto.conf "${ROOTFS_DIR}/etc/mosquitto/conf.d/"

mkdir -p "${ROOTFS_DIR}/var/log/mosquitto"

mkdir -p "${ROOTFS_DIR}/opt/gardenback"
install -m 644 files/.env "${ROOTFS_DIR}/opt/gardenback/"

on_chroot << EOF
lighty-enable-mod proxy
lighty-enable-mod rewrite

sed -i '0,/\/var\/www\/html/s//\/var\/www\/html\/web\//g' /etc/lighttpd/lighttpd.conf


ln -sf /etc/lighttpd/conf-available/10-gardenback-proxy.conf /etc/lighttpd/conf-enabled/10-gardenback-proxy.conf

systemctl enable mosquitto.service
systemctl enable lighttpd.service
systemctl enable garden_back.service
EOF