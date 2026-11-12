# ProString — QZ Tray Installers

Public repository for **standalone QZ Tray installers** required by ProString.

## 📥 Downloads

- **Windows:** [`install-qz-tray-win.exe`](../../releases/latest/download/install-qz-tray-win.exe) (32.5 MB)
- **macOS:** [`install-qz-tray-macos`](../../releases/latest/download/install-qz-tray-macos) (44.1 MB)
- **Linux:** [`install-qz-tray-linux`](../../releases/latest/download/install-qz-tray-linux) (39.9 MB)

Or go to [Releases](../../releases/) to see all versions.

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
3. Run: `./install-qz-tray-macos`
4. Enter your password when prompted
5. Done!

### Linux

1. Download `install-qz-tray-linux`
2. Open Terminal
3. Run: `./install-qz-tray-linux`
4. Enter your password when prompted
5. Done!



## 🍎 macOS: "Apple could not verify... is free of malware"

The installer isn't notarized by Apple, so Gatekeeper blocks it by default the first time. Two options:

### Option A — Allow it and run the installer (recommended)

1. Right-click (or Control-click) `install-qz-tray-macos` → **Open** (do NOT double-click)
2. In the dialog, click **Open** again — this is different from the "Not Opened" popup you get from double-clicking, and only appears via right-click → Open
3. If you already dismissed it with "Done"/"Move to Bin" instead: go to **System Settings → Privacy & Security**, scroll down to the Security section, and click **"Open Anyway"** next to the message about `install-qz-tray-macos`, then confirm
4. Once allowed once, run it from Terminal:
   ```bash
   cd ~/Downloads
   chmod +x install-qz-tray-macos
   ./install-qz-tray-macos
   ```
5. Enter your password when prompted → Done!

### Option B — Manual installation (no installer binary at all)

If you'd rather not run the unsigned binary, do exactly what it automates:

1. **Install QZ Tray itself** (official, signed by QZ Industries):
   - Download: [qz-tray-2.2.6-macos.dmg](https://github.com/qzind/tray/releases/download/v2.2.6/qz-tray-2.2.6-macos.dmg)
   - Open the `.dmg` and drag **QZ Tray.app** into **Applications**
2. **Install the ProString certificate:**
   - Download: [override.crt](https://prostringmanage.com/qz/override.crt)
   - Move/copy it into: `/Applications/QZ Tray.app/Contents/Resources/override.crt`
     ```bash
     cp ~/Downloads/override.crt "/Applications/QZ Tray.app/Contents/Resources/override.crt"
     ```
3. **Start QZ Tray:**
   - Open it from Applications (right-click → Open the first time, same Gatekeeper step as above, since QZ Tray itself is also unsigned for direct download)
   - Look for the printer icon in the menu bar
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
**Updated:** 2026-06-05
