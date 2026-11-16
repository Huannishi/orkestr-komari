#!/bin/sh
# Komari probe + tiny web server for orkestr free project
set -u

PORT="${PORT:-3000}"
SERVER="https://komari.batk.de5.net"

# pick agent binary for this arch
case "$(uname -m)" in
  x86_64)  ARCH="amd64" ;;
  aarch64) ARCH="arm64" ;;
  *)       ARCH="amd64" ;;
esac

if [ ! -x /tmp/komari-agent ]; then
  echo "downloading komari-agent (linux-$ARCH)..."
  curl -fsSL -o /tmp/komari-agent \
    "https://github.com/komari-monitor/komari-agent/releases/latest/download/komari-agent-linux-$ARCH" \
    && chmod +x /tmp/komari-agent \
    || echo "agent download FAILED"
fi

# run agent with a restart loop in background
(
  while true; do
    if [ -x /tmp/komari-agent ] && [ -n "${KOMARI_TOKEN:-}" ]; then
      /tmp/komari-agent -e "$SERVER" -t "$KOMARI_TOKEN" || true
    fi
    sleep 5
  done
) &

# foreground: tiny web server so the platform sees a healthy app
cd /app
exec python3 -m http.server "$PORT" --bind 0.0.0.0
