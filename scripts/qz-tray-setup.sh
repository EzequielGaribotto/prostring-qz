#!/bin/bash
# QZ Tray setup for ProString on macOS and Linux: installs QZ Tray (if missing), installs
# ProString's certificate (override.crt) and restarts QZ Tray.
#
# Options (environment variables):
#   QZ_TRAY_VERSION          QZ Tray version to install (default below; a release of qzind/tray)
#   QZ_SETUP_NONINTERACTIVE  set to 1 to skip the final "press any key" pause (CI)
#   $1                       certificate URL (default below)
set -u

QZ_VERSION="${QZ_TRAY_VERSION:-2.3.0}"
CERTIFICATE_URL="${1:-https://prostringmanage.com/qz/override.crt}"
RELEASE_URL="https://github.com/qzind/tray/releases/download/v${QZ_VERSION}"

echo "QZ Tray Setup - Linux/macOS"

OS_TYPE=$(uname -s)
case "$(uname -m)" in
    arm64|aarch64) ARCH="arm64" ;;
    x86_64|amd64)  ARCH="x86_64" ;;
    riscv64)       ARCH="riscv64" ;;
    *) echo "Unsupported processor: $(uname -m)"; exit 1 ;;
esac

if [ "$OS_TYPE" = "Darwin" ]; then
    APP_DIR="/Applications/QZ Tray.app"
    CERT_DIR="$APP_DIR/Contents/Resources"
else
    APP_DIR="/opt/qz-tray"
    CERT_DIR="/opt/qz-tray"
fi

if [ ! -d "$APP_DIR" ]; then
    # The installers on qzind/tray are named qz-tray-<version>-<arch>.pkg (macOS) and .run (Linux).
    if [ "$OS_TYPE" = "Darwin" ]; then
        FILE="qz-tray-${QZ_VERSION}-${ARCH}.pkg"
    else
        FILE="qz-tray-${QZ_VERSION}-${ARCH}.run"
    fi
    TMP_FILE="/tmp/${FILE}"

    echo "Downloading QZ Tray ${QZ_VERSION} (${FILE}) from GitHub..."
    # -f: an HTTP error (404...) must fail here instead of saving an error page as the installer.
    if ! curl -fL -o "$TMP_FILE" "${RELEASE_URL}/${FILE}"; then
        echo "Error downloading QZ Tray from ${RELEASE_URL}/${FILE}"
        exit 1
    fi

    echo "Installing QZ Tray (your password may be asked)..."
    if [ "$OS_TYPE" = "Darwin" ]; then
        if ! sudo installer -pkg "$TMP_FILE" -target /; then
            echo "The QZ Tray installer failed"
            rm -f "$TMP_FILE"
            exit 1
        fi
    else
        if ! sudo sh "$TMP_FILE"; then
            echo "The QZ Tray installer failed"
            rm -f "$TMP_FILE"
            exit 1
        fi
    fi
    rm -f "$TMP_FILE"
    echo "QZ Tray installed"
else
    echo "QZ Tray already installed"
fi

if [ ! -d "$CERT_DIR" ]; then
    echo "QZ Tray folder not found: $CERT_DIR"
    exit 1
fi

echo "Downloading certificate..."
TMP_CERT="$(mktemp)"
if ! curl -fL -o "$TMP_CERT" "$CERTIFICATE_URL"; then
    echo "Error downloading certificate from $CERTIFICATE_URL"
    rm -f "$TMP_CERT"
    exit 1
fi
# The QZ Tray folder belongs to root, so the copy needs sudo.
if ! sudo cp "$TMP_CERT" "$CERT_DIR/override.crt"; then
    echo "Could not write $CERT_DIR/override.crt"
    rm -f "$TMP_CERT"
    exit 1
fi
rm -f "$TMP_CERT"
echo "Certificate installed in $CERT_DIR"

echo "Restarting QZ Tray..."
pkill -f "QZ Tray" || true
pkill -f qz-tray || true
sleep 2

if [ "$OS_TYPE" = "Darwin" ]; then
    open -a "$APP_DIR"
else
    nohup /opt/qz-tray/qz-tray >/dev/null 2>&1 &
fi

echo "Setup Complete!"
echo "Next steps:"
echo "1. If QZ Tray shows a security dialog, click Allow"
echo "2. Configure printers in ProString Settings"
echo ""

if [ "${QZ_SETUP_NONINTERACTIVE:-}" != "1" ]; then
    echo "Press any key to exit..."
    read -n 1
fi
