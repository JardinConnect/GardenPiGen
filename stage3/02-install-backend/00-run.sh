#!/bin/bash -e

on_chroot << EOF
apt-get update
apt-get install -y python3-pip python3-venv lighttpd mosquitto mosquitto-clients python3-dev build-essential
EOF

# Copy backend files
mkdir -p "${ROOTFS_DIR}/opt/gardenback"
if [ -d "files/backend" ] && [ "$(ls -A files/backend)" ]; then
    cp -r files/backend/* "${ROOTFS_DIR}/opt/gardenback/"
else
    echo "WARNING: files/backend is empty. Backend will not be installed."
    echo "Please copy your GardenBack source code to stage3/02-install-backend/files/backend/"
fi

# Setup backend if files exist
if [ -f "${ROOTFS_DIR}/opt/gardenback/requirements.txt" ]; then
    on_chroot << EOF
cd /opt/gardenback

# Setup Virtual Environment
python3 -m venv venv
source venv/bin/activate

# Upgrade pip
pip3 install --upgrade pip

# Install requirements
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
fi