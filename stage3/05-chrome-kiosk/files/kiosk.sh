#!/bin/bash

# Get the URL from config file or use localhost
KIOSK_URL="${KIOSK_URL:-http://localhost}"

# Use Wayland backend
export XDG_RUNTIME_DIR=/run/user/$(id -u)
export XDG_SESSION_TYPE=wayland
export MOZ_ENABLE_WAYLAND=1

# Start cage (Wayland kiosk compositor) with Firefox
# Cage displays a single fullscreen window and prevents switching
cage -s -- firefox-esr \
  --kiosk \
  "${KIOSK_URL}"
