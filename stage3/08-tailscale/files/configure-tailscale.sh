#!/bin/bash
# Configure Tailscale to use garden.connect domain
# This script should be run after the device is connected to Tailscale network

# Enable MagicDNS and HTTPS
tailscale set --hostname=garden-connect

