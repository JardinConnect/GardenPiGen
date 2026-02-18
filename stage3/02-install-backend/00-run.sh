#!/bin/bash -e

# Install systemd service (always install even if backend files missing)
install -m 644 files/garden_back.service "${ROOTFS_DIR}/etc/systemd/system/"

# Install lighttpd proxy configuration
install -m 644 files/10-gardenback-proxy.conf "${ROOTFS_DIR}/etc/lighttpd/conf-available/"

# Install mosquitto configuration
install -m 644 files/mosquitto.conf "${ROOTFS_DIR}/etc/mosquitto/conf.d/"

# Create mosquitto log directory
mkdir -p "${ROOTFS_DIR}/var/log/mosquitto"

# Install environment configuration
mkdir -p "${ROOTFS_DIR}/opt/gardenback"
install -m 644 files/.env "${ROOTFS_DIR}/opt/gardenback/"

on_chroot << EOF
# Enable lighttpd proxy module
lighty-enable-mod proxy

# Enable GardenBack proxy configuration
ln -sf /etc/lighttpd/conf-available/10-gardenback-proxy.conf /etc/lighttpd/conf-enabled/10-gardenback-proxy.conf

# Enable services
systemctl enable mosquitto.service
systemctl enable lighttpd.service
systemctl enable garden_back.service
EOF

# Check if backend files exist
if [ ! -d "files/backend" ] || [ -z "$(ls -A files/backend)" ]; then
    echo "WARNING: files/backend is empty or missing!"
    echo "Backend service is enabled but will fail to start without code."
    echo "Please copy your GardenBack source code to stage3/02-install-backend/files/backend/"
    exit 0
fi

# Copy backend files
mkdir -p "${ROOTFS_DIR}/opt/gardenback"
cp -r files/backend/* "${ROOTFS_DIR}/opt/gardenback/"

# Verify requirements.txt exists
if [ ! -f "${ROOTFS_DIR}/opt/gardenback/requirements.txt" ]; then
    echo "ERROR: requirements.txt not found in backend files!"
    exit 1
fi

# Setup backend
on_chroot << EOF
cd /opt/gardenback

# Setup Virtual Environment
python3 -m venv venv
source venv/bin/activate

# Install requirements (skip pip upgrade to save time)
pip3 install -r requirements.txt

# Initialize database if alembic exists
if [ -f "alembic.ini" ]; then
    python3 -m alembic upgrade head
fi
EOF

# Set permissions
on_chroot << EOF
chown -R root:root /opt/gardenback
chmod -R 755 /opt/gardenback
EOF