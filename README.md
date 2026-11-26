# ProString — QZ Tray Installers

Public repository for **standalone QZ Tray installers** required by ProString.

## 📥 Downloads

- **Windows:** [`install-qz-tray-win.exe`](../../releases/latest/download/install-qz-tray-win.exe)
- **macOS:** [`install-qz-tray-macos`](../../releases/latest/download/install-qz-tray-macos) (a shell script)
- **Linux:** [`install-qz-tray-linux`](../../releases/latest/download/install-qz-tray-linux) (a shell script)

Or go to [Releases](../../releases/) to see all versions. Each release lists the SHA-256 of its files.

---

## 🚀 Quick Start

### Windows

1. Download `install-qz-tray-win.exe`
2. Right-click → "Run as administrator"
3. Follow the prompts
4. Done!

### macOS

1. Download `install-qz-tray-macos`
2. Open Terminal
3. Run: `cd ~/Downloads` then `bash install-qz-tray-macos`
4. Enter your password when prompted
5. Done!

The macOS and Linux installers are plain shell scripts (the same file as
[`scripts/qz-tray-setup.sh`](scripts/qz-tray-setup.sh)): read them before running them if you like. Run from
Terminal, they need no Rosetta and no Gatekeeper approval. Never pipe them from the internet into a shell
(`curl ... | bash`): download, read, then run.

### Linux

1. Download `install-qz-tray-linux`
2. Open Terminal
3. Run: `cd ~/Downloads` then `bash install-qz-tray-linux`
4. Enter your password when prompted
5. Done!

## 🔒 What the installers check

- **QZ Tray itself** is downloaded from the official release ([qzind/tray](https://github.com/qzind/tray/releases))
  and installed only if its SHA-256 matches the value pinned in the script. A file with no pinned value
  (another version, a re-published file) is refused.
- **ProString's certificate** (`override.crt`, from `https://prostringmanage.com/qz/override.crt`) is installed
  only if its SHA-256 fingerprint is
  `cb277265a6afb2536c87c6ca76bf44da63ecb6dd1ba99d0c40ef980bbdcfda04`.

## 🛠️ Manual installation (no installer at all)

Do by hand exactly what the installer automates:

1. **Install QZ Tray itself** (official, signed by QZ Industries), from the
   [QZ Tray 2.3.0 release](https://github.com/qzind/tray/releases/tag/v2.3.0):
   - Windows: `qz-tray-2.3.0+1-x86_64.exe` (`arm64.exe` on ARM)
   - macOS: `qz-tray-2.3.0+1-arm64.pkg` (Apple silicon) or `qz-tray-2.3.0+1-x86_64.pkg` (Intel)
   - Linux: `qz-tray-2.3.0+1-x86_64.run` (`arm64.run` on ARM)
2. **Install the ProString certificate:** download [override.crt](https://prostringmanage.com/qz/override.crt)
   and copy it into the QZ Tray folder, replacing any file with that name:
   - Windows: `C:\Program Files\QZ Tray\override.crt`
   - macOS: `/Applications/QZ Tray.app/Contents/Resources/override.crt`
     ```bash
     sudo cp ~/Downloads/override.crt "/Applications/QZ Tray.app/Contents/Resources/override.crt"
     ```
   - Linux: `/opt/qz-tray/override.crt`
3. **Start QZ Tray** (or restart it if it was running) and look for its printer icon.
4. **Connect ProString:** Settings → Printer Settings → **Reconnect**, then accept the one-time authorization prompt

---

## After that

1. **Verify**

    - Look for a **printer icon** in your system tray (bottom-right)
    - That's QZ Tray running!
2. **Configure ProString**

    - Open ProString
    - Go to Settings → Printer Settings
    - Click "Reconnect"
    - Your printers should appear in the dropdown, and you won't see again the authorize prompt after you accept it once



---

## ❓ What Is This?

QZ Tray is a background application that routes print jobs directly to your printers without browser dialogs.

This repository contains **standalone installers** for QZ Tray configured for ProString. They automatically:

- ✅ Download & install QZ Tray
- ✅ Configure the ProString certificate
- ✅ Start QZ Tray
- ✅ Enable seamless printing

---

## 📄 License

ProString is proprietary software. QZ Tray is open source (LGPL).

---

**Latest Release:** Check [Releases](../../releases/)
**Updated:** 2026-11-26
