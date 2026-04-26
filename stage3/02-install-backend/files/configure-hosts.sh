#!/bin/bash -e
# Configure /etc/hosts for garden.connect domain

# Add garden.connect to /etc/hosts
cat >> /etc/hosts << EOF

# Garden local domain
127.0.0.1 garden.connect
EOF
