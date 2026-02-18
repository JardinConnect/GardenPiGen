#!/bin/bash -e

# Clone GardenBack from git submodule
SUBMODULE_PATH="${BASE_DIR}/back/GardenBack"

if [ ! -d "${SUBMODULE_PATH}" ] || [ -z "$(ls -A ${SUBMODULE_PATH})" ]; then
    echo "ERROR: GardenBack submodule not initialized!"
    echo "Please run: git submodule update --init --recursive"
    exit 1
fi

# Copy backend files from submodule
mkdir -p "${ROOTFS_DIR}/opt/gardenback"
cp -r "${SUBMODULE_PATH}"/* "${ROOTFS_DIR}/opt/gardenback/"

# Verify requirements.txt exists
if [ ! -f "${ROOTFS_DIR}/opt/gardenback/requirements.txt" ]; then
    echo "ERROR: requirements.txt not found in GardenBack repository!"
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
# if [ -f "alembic.ini" ]; then
#     python3 -m alembic upgrade head
# fi
EOF

# Set permissions
on_chroot << EOF
chown -R root:root /opt/gardenback
chmod -R 755 /opt/gardenback
EOF