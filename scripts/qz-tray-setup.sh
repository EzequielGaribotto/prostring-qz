#!/bin/bash
# QZ Tray setup for ProString on macOS and Linux: installs QZ Tray (if missing), installs
# ProString's certificate (override.crt) and restarts QZ Tray.
#
# Options (environment variables):
#   QZ_TRAY_VERSION          QZ Tray release tag to install (default below; a release of qzind/tray)
#   QZ_TRAY_BUILD            version in that release's file names (QZ re-published 2.3.0 as "2.3.0+1")
#   QZ_ALLOW_UNPINNED        set to 1 to install a file with no pinned checksum below (testing only)
#   QZ_SETUP_NONINTERACTIVE  set to 1 to skip the final "press any key" pause (CI)
#   $1                       certificate URL (default below)
set -u

QZ_VERSION="${QZ_TRAY_VERSION:-2.3.0}"
if [ -n "${QZ_TRAY_BUILD:-}" ]; then QZ_BUILD="$QZ_TRAY_BUILD"
elif [ "$QZ_VERSION" = "2.3.0" ]; then QZ_BUILD="2.3.0+1"
else QZ_BUILD="$QZ_VERSION"; fi
CERTIFICATE_URL="${1:-https://prostringmanage.com/qz/override.crt}"
RELEASE_URL="https://github.com/qzind/tray/releases/download/v${QZ_VERSION}"
# SHA-256 of ProString's certificate (https://prostringmanage.com/qz/override.crt, valid until 2046).
CERT_SHA256="cb277265a6afb2536c87c6ca76bf44da63ecb6dd1ba99d0c40ef980bbdcfda04"

# The installer runs as root: each file must match the SHA-256 GitHub publishes for it (gh release view
# v<version> -R qzind/tray --json assets). A new QZ version or re-published file needs its line here.
pinned_sha256() {
    case "$1" in
        qz-tray-2.3.0+1-arm64.pkg)   echo 18243ea01f500b03668c4ca0a59e343cd79bd5d2e19d050cb2f7871907fb5104 ;;
        qz-tray-2.3.0+1-x86_64.pkg)  echo 36e86768710cc7eabd51615a9da8694ed6bead747c576eab958b760d5ff6d29d ;;
        qz-tray-2.3.0+1-arm64.run)   echo f441f3ae254cf5789f2369d0335e052f5d68e7fecfcb7a0aa2bd2c53401b405f ;;
        qz-tray-2.3.0+1-x86_64.run)  echo 7860322099e83b36a3d6db59a5c1a406dfb8749b15ac78c1f67744dd207e9bde ;;
        qz-tray-2.3.0+1-riscv64.run) echo 435f327d77546cb9af56daae270c4a94cab021bc85ffc30a643ade457f8a6ca7 ;;
        *) echo "" ;;
    esac
}

sha256_of() {
    if command -v shasum >/dev/null 2>&1; then shasum -a 256 "$1" | cut -d' ' -f1
    else sha256sum "$1" | cut -d' ' -f1; fi
}

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
    # The installers on qzind/tray are named qz-tray-<build>-<arch>.pkg (macOS) and .run (Linux).
    if [ "$OS_TYPE" = "Darwin" ]; then
        FILE="qz-tray-${QZ_BUILD}-${ARCH}.pkg"
    else
        FILE="qz-tray-${QZ_BUILD}-${ARCH}.run"
    fi
    EXPECTED="$(pinned_sha256 "$FILE")"
    if [ -z "$EXPECTED" ] && [ "${QZ_ALLOW_UNPINNED:-}" != "1" ]; then
        echo "No pinned checksum for ${FILE}: refusing to install it."
        exit 1
    fi
    TMP_FILE="$(mktemp -d)/${FILE}"
    URL="${RELEASE_URL}/$(printf '%s' "$FILE" | sed 's/+/%2B/g')"

    echo "Downloading QZ Tray ${QZ_BUILD} (${FILE}) from GitHub..."
    # -f: an HTTP error (404...) must fail here instead of saving an error page as the installer.
    if ! curl -fL -o "$TMP_FILE" "$URL"; then
        echo "Error downloading QZ Tray from ${URL}"
        exit 1
    fi
    if [ -n "$EXPECTED" ]; then
        ACTUAL="$(sha256_of "$TMP_FILE")"
        if [ "$ACTUAL" != "$EXPECTED" ]; then
            echo "Checksum mismatch for ${FILE}: expected ${EXPECTED}, got ${ACTUAL}. Not installing."
            rm -f "$TMP_FILE"
            exit 1
        fi
        echo "Checksum OK"
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
# Only ProString's own certificate is accepted from the default address (its SHA-256 fingerprint).
if [ "$CERTIFICATE_URL" = "https://prostringmanage.com/qz/override.crt" ]; then
    if command -v openssl >/dev/null 2>&1; then
        FP="$(openssl x509 -in "$TMP_CERT" -noout -fingerprint -sha256 2>/dev/null | cut -d= -f2 | tr -d ':' | tr 'A-F' 'a-f')"
        if [ "$FP" != "$CERT_SHA256" ]; then
            echo "The downloaded certificate is not ProString's certificate. Not installing it."
            rm -f "$TMP_CERT"
            exit 1
        fi
    else
        echo "openssl not found: the certificate's fingerprint is not checked."
    fi
fi
# The QZ Tray folder belongs to root, so the copy needs sudo. `install -m 644` makes the file readable
# by QZ Tray (a plain copy of the private temp file would be root-only, and QZ would ignore it).
if ! sudo install -m 644 "$TMP_CERT" "$CERT_DIR/override.crt"; then
    echo "Could not write $CERT_DIR/override.crt"
    rm -f "$TMP_CERT"
    exit 1
fi
rm -f "$TMP_CERT"
echo "Certificate installed in $CERT_DIR"

echo "Restarting QZ Tray..."
# Match the process by what only QZ Tray has in its command line: matching "qz-tray" would also kill
# this script (qz-tray-setup.sh). The Linux installer starts QZ Tray as root, hence sudo there.
if [ "$OS_TYPE" = "Darwin" ]; then
    pkill -f "QZ Tray.app" || true
else
    sudo pkill -f "qz-tray.jar" || true
fi
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
