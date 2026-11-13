# QZ Tray Installer — Complete Solution

This directory contains everything needed to install QZ Tray for ProString, including standalone executables for Windows, macOS, and Linux.

## 📦 Contents

- **`install-qz-tray-windows.ps1`** — PowerShell script for Windows (automated)
- **`install-qz-tray-unix.sh`** — Bash script for macOS/Linux (automated)
- **`installer.mjs`** — Node.js entry point (cross-platform orchestration)
- **`package.json`** — Build configuration for standalone executables
- **`BUILD.md`** — Detailed build instructions
- **`QZ_TRAY_INSTALL_README.md`** — User-facing setup guide
- **`build-installers.md`** — Advanced customization guide

## 🚀 Quick Start for End Users

### Windows
1. Download `install-qz-tray-win.exe`
2. Right-click → "Run as administrator"
3. Follow the prompts
4. Done! QZ Tray will start automatically

### macOS
1. Download `install-qz-tray-macos`
2. Open Terminal
3. Run: `./install-qz-tray-macos`
4. Enter your password when prompted
5. Done! QZ Tray will start automatically

### Linux
1. Download `install-qz-tray-linux`
2. Open Terminal
3. Run: `./install-qz-tray-linux`
4. Enter your password when prompted
5. Done! QZ Tray will start automatically

## 🛠️ For Developers: Building Executables

### Prerequisites
```bash
# Install Node.js 18+
node --version  # Should show v18 or later

# Install dependencies
npm install
```

### Build All Platforms
```bash
npm run build
```

Output:
- `dist/install-qz-tray-win.exe` — Windows
- `dist/install-qz-tray-macos` — macOS
- `dist/install-qz-tray-linux` — Linux

Upload these to a GitHub Release (the app downloads the latest release assets); `dist/` is not committed.

### Build Single Platform
```bash
npm run build:win     # Windows only
npm run build:macos   # macOS only
npm run build:linux   # Linux only
```

## 📋 What Gets Installed

The installer performs these steps **automatically**:

### Step 1: Download & Install QZ Tray
- Downloads the latest QZ Tray from https://qz.io/download/
- Installs it to:
  - **Windows:** `C:\Program Files\QZ Tray\`
  - **macOS:** `~/Applications/QZ Tray.app`
  - **Linux:** `/opt/qz-tray`

### Step 2: Install ProString Certificate
- Downloads `override.crt` (trusts ProString with QZ Tray)
- Places it in the correct location for QZ Tray to find it
- No more "allow permission" dialogs on every print job!

### Step 3: Start QZ Tray
- Stops any running instances
- Starts QZ Tray fresh with the certificate loaded
- Adds to system tray/menu bar

## 🔌 Integration in ProString UI

Users can access this guide directly from **Settings → Printer Settings**:

1. Click the **?** button next to "Printers (QZ Tray)"
2. A draggable tooltip appears with:
   - ✅ Non-technical explanation (what, why, how)
   - 🖥️ Platform-specific tabs (Windows/macOS/Linux)
   - 📥 Download button for their OS
   - 📝 Step-by-step instructions
   - ⏭️ What comes next after installation

The tooltip auto-detects the user's OS and shows the right tab first.

## 📁 Directory Structure

```
scripts/
├── install-qz-tray-windows.ps1    # PowerShell script (Windows)
├── install-qz-tray-unix.sh        # Bash script (macOS/Linux)
├── installer.mjs                   # Node.js orchestrator
├── package.json                    # Build config
├── BUILD.md                        # Build instructions
├── build-installers.md             # Advanced customization
├── QZ_TRAY_INSTALL_README.md       # Legacy user guide
├── README.md                       # This file
└── dist/                           # Generated executables (after build)
    ├── install-qz-tray-win.exe
    ├── install-qz-tray-macos
    └── install-qz-tray-linux
```

## 🔄 Workflow

### For End Users
1. Go to ProString Settings → Printer Settings
2. Click **?** button next to "Printers (QZ Tray)"
3. Follow the guide (auto-detects their OS)
4. Click **Download** button
5. Run the downloaded installer
6. Done!

### For Developers
1. Make changes to the scripts (`install-qz-tray-*.ps1`, `installer.mjs`, etc.)
2. Test locally:
   ```bash
   # Windows (PowerShell)
   & ".\install-qz-tray-windows.ps1"
   
   # macOS/Linux (bash)
   bash install-qz-tray-unix.sh
   ```
3. Build executables:
   ```bash
   npm run build
   ```
4. Upload to GitHub Releases or your server
5. Update the download URLs in the Vue component (`QZTrayInstallGuide.vue`)

## 🔗 Download URLs

Update these in `app/src/components/QZTrayInstallGuide.vue` (around line 20):

```javascript
const executables: Record<string, { name: string; url: string }> = {
  windows: {
    name: 'install-qz-tray-win.exe',
    url: 'https://your-domain.com/downloads/install-qz-tray-win.exe'
  },
  macos: {
    name: 'install-qz-tray-macos',
    url: 'https://your-domain.com/downloads/install-qz-tray-macos'
  },
  linux: {
    name: 'install-qz-tray-linux',
    url: 'https://your-domain.com/downloads/install-qz-tray-linux'
  },
}
```

## 🧪 Testing

### Smoke Test (Verify UI)
```bash
cd app
npm run dev
# Visit http://localhost:5173/dev/settings
# Log in, go to Printer Settings
# Click ? button, verify tooltip appears with tabs
```

### Script Test (Verify Installation Logic)
```bash
# Windows (PowerShell, as admin)
& ".\install-qz-tray-windows.ps1"

# macOS/Linux (bash)
bash install-qz-tray-unix.sh
```

### Full Build Test
```bash
npm run build
# Test each binary on its respective OS
```

## 🐛 Troubleshooting

### "Script execution is disabled"
**Windows PowerShell error**

Fix: Run as Administrator, then:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### "Permission denied"
**macOS/Linux error**

Fix:
```bash
chmod +x install-qz-tray-macos
./install-qz-tray-macos
```

### "QZ Tray not found after installation"
Check the installation paths:
- **Windows:** `C:\Program Files\QZ Tray\qz-tray.exe`
- **macOS:** `~/Applications/QZ Tray.app/Contents/MacOS/QZ Tray`
- **Linux:** `/opt/qz-tray/qz-tray`

If not found, QZ Tray download failed — check internet connection and download manually from https://qz.io/download/

### "Certificate download failed"
Verify the certificate URL is accessible:
```bash
curl -v http://localhost:5173/override.crt
# Should return 200 OK and the .crt file contents
```

## 📝 Notes

- The **executor** (`.exe`, `.app`, `.bin`) bundles Node.js 18+ — no separate installation needed
- **Admin rights** are required only for the installation step (QZ Tray, certificate placement)
- **No telemetry** — installers don't phone home
- **Offline capable** — after QZ Tray is installed, ProString works without internet (except for updates)

## 🔐 Security

- Scripts are **open source** — users can inspect before running
- No credentials or API keys in the code
- Only downloads from official QZ Tray repository and your own server
- Bash and PowerShell are standard system tools (no 3rd-party dependencies)

## 📞 Support

- **QZ Tray issues?** → https://qz.io/support
- **ProString issues?** → Check SETUP_CLIENT.md or contact your administrator
- **Installer issues?** → Check troubleshooting above or review the script logs

## 🎯 Next Steps

1. ✅ Verify ProString Settings UI shows the **?** button
2. ✅ Build executables: `npm run build`
3. ✅ Upload to GitHub Releases or your server
4. ✅ Update download URLs in `QZTrayInstallGuide.vue`
5. ✅ Test on all three platforms
6. ✅ Distribute to users!

---

**Happy stringing! 🎾**
