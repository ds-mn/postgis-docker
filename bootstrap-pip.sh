#!/bin/bash -e

if [ -n "$PIP_PACKAGES" ]; then
  pip3 install --no-cache-dir --progress-bar off "$PIP_PACKAGES"
fi

exec "$@"
