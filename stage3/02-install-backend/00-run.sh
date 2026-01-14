#!/bin/bash -e

# Check if backend files exist
if [ ! -d "files/backend" ] || [ -z "$(ls -A files/backend)" ]; then
    echo "ERROR: files/backend is empty or missing!"
    echo "Please copy your GardenBack source code to stage3/02-install-backend/files/backend/"
    exit 1
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

# Upgrade pip
pip3 install --upgrade pip

# Install requirements with retries and timeout
pip3 install --retries 10 --timeout 60 -r requirements.txt

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