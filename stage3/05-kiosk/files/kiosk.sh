#!/bin/bash

KIOSK_URL="${KIOSK_URL:-http://localhost}"

export XDG_RUNTIME_DIR=/run/user/$(id -u)
export XDG_SESSION_TYPE=wayland
export OZONE_PLATFORM=wayland


cage -s -- chromium \
  --ozone-platform=wayland \
  --enable-features=UseOzonePlatform \
  --kiosk \
  "${KIOSK_URL}"
