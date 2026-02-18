#!/bin/bash

KIOSK_URL="${KIOSK_URL:-http://localhost}"

export XDG_RUNTIME_DIR=/run/user/$(id -u)
export XDG_SESSION_TYPE=wayland
export MOZ_ENABLE_WAYLAND=1


cage -s -- firefox-esr \
  --kiosk \
  "${KIOSK_URL}"
