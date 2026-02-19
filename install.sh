#!/bin/bash
set -e

REPO="sreehb-123/ctc"
BRANCH="main"
RAW="https://raw.githubusercontent.com/${REPO}/${BRANCH}"

echo "==> Installing ctc..."
echo "This installer may require administrator privileges."
sudo -v

# Keep sudo alive
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Check for wl-clipboard
if ! command -v wl-copy >/dev/null 2>&1; then
    echo ""
    echo "wl-clipboard is required but not installed."
    read -p "Install wl-clipboard now? [Y/n]: " choice
    choice=${choice:-Y}
    if [[ "$choice" =~ ^[Yy]$ ]]; then
        echo "Installing wl-clipboard..."
        sudo apt update
        sudo apt install -y wl-clipboard
    else
        echo "Cannot continue without wl-clipboard."
        exit 1
    fi
fi

# Download files to a temp directory
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

echo "Downloading ctc..."
curl -fsSL "${RAW}/ctc" -o "${TMP}/ctc"
curl -fsSL "${RAW}/ctc.1.gz" -o "${TMP}/ctc.1.gz"

# Install binary
echo "Installing binary..."
sudo install -m 755 "${TMP}/ctc" /usr/local/bin/ctc

# Install man page
echo "Installing man page..."
sudo mkdir -p /usr/local/share/man/man1
sudo install -m 644 "${TMP}/ctc.1.gz" /usr/local/share/man/man1/

# Update man database
sudo mandb >/dev/null 2>&1 || true

echo ""
echo "✅ ctc installed successfully!"
echo "Run: ctc -h"
