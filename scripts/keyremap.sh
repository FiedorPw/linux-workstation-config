#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🔧 Setting up keyd for key remapping..."

# Install keyd if not present
install_keyd_from_source() {
  echo "   -> Building keyd from source..."
  cd /tmp
  git clone https://github.com/rvaiya/keyd.git keyd-build
  cd keyd-build
  make
  sudo make install
  cd /tmp && rm -rf keyd-build
}

if ! command -v keyd >/dev/null 2>&1; then
  if command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y keyd 2>/dev/null || install_keyd_from_source
  elif command -v apt >/dev/null 2>&1; then
    sudo apt install -y keyd 2>/dev/null || install_keyd_from_source
  else
    install_keyd_from_source
  fi
fi

# Check if keyd was installed successfully
if ! command -v keyd >/dev/null 2>&1; then
  echo -e "\033[0;31m⚠️  keyd installation failed - skipping key remapping\033[0m"
  exit 0
fi

# Copy keyd config
sudo mkdir -p /etc/keyd
sudo cp -f "$SCRIPT_DIR/keyd/default.conf" /etc/keyd/default.conf

# Enable and start keyd service
sudo systemctl enable --now keyd || true
sudo keyd reload || true

echo "✅ Key remapping applied via keyd"
