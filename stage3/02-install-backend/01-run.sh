#!/bin/bash -e

# Check if backend files exist before attempting to copy
if [ ! -d "files/backend" ] || [ -z "$(ls -A files/backend)" ]; then
    echo "Skipping backend installation - no backend files found"
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