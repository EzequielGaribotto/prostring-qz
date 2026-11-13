# Testing Guide — QZ Tray Installers

Before releasing executables, test them thoroughly on each platform.

---

## 🧪 Pre-Release Testing

### Test Environment Setup

You need to test on at least one machine per OS, or use VMs:

- **Windows:** Native Windows 10/11 or VM
- **macOS:** Native macOS or VM
- **Linux:** Ubuntu 20.04+ or equivalent

### Prerequisites

- [ ] QZ Tray NOT currently installed (fresh test)
- [ ] Admin/sudo rights available
- [ ] Internet connection
- [ ] ProString accessible at your test domain
- [ ] Certificate accessible at `https://prostringmanage.com/qz/override.crt`

---

## 🪟 Windows Testing

### Phase 1: Verify Executable

```powershell
# Check file exists and is reasonable size
ls -la install-qz-tray-win.exe
# Should be ~37 MB
```

- [ ] File exists
- [ ] File size is ~37 MB (not 0 bytes)
- [ ] File is executable

### Phase 2: Run Installer

1. **Download the exe** (or copy from releases repo)
2. **Right-click** → "Run as Administrator"
3. **If SmartScreen appears:** Click "More info" → "Run anyway"
4. **Watch the installation:**
   - [ ] "QZ Tray Setup - Windows" message appears
   - [ ] "Downloading QZ Tray installer..." 
   - [ ] "Running QZ Tray installer..."
   - [ ] "Downloading certificate from..."
   - [ ] "✓ Certificate installed at..."
   - [ ] "Restarting QZ Tray..."
   - [ ] "✓ QZ Tray started"
   - [ ] "Setup Complete!" message

### Phase 3: Verify Installation

1. **Check system tray:**
   - [ ] Printer icon appears (bottom-right)
   - [ ] Right-click → menu shows options

2. **Check file locations:**
   ```powershell
   # Verify QZ Tray installed
   Test-Path "C:\Program Files\QZ Tray\qz-tray.exe"
   # Should return True

   # Verify certificate installed
   Test-Path "C:\Program Files\QZ Tray\override.crt"
   # Should return True

   # Check certificate content
   Get-Content "C:\Program Files\QZ Tray\override.crt" | Select-Object -First 1
   # Should start with: -----BEGIN CERTIFICATE-----
   ```

3. **Check running process:**
   ```powershell
   Get-Process qz-tray -ErrorAction SilentlyContinue
   # Should show qz-tray process running
   ```

### Phase 4: Test with ProString

1. **Open ProString** at `https://app.prostringmanage.com`
2. **Go to:** Settings → Printer Settings
3. **Check QZ connection:**
   - [ ] Green dot appears next to "QZ Tray: connected"
4. **Click "Reconnect":**
   - [ ] Printers appear in dropdowns
   - [ ] Can select receipt and label printers
5. **Test print:**
   - [ ] Create a simple order
   - [ ] Click print
   - [ ] Printer job sent without browser dialog
   - [ ] Check printer received the job

### Phase 5: Uninstall & Verify Cleanup

```powershell
# Uninstall
Settings → Apps → Apps & features → QZ Tray → Uninstall

# Verify uninstalled
Test-Path "C:\Program Files\QZ Tray"
# Should return False
```

- [ ] Uninstall completes
- [ ] QZ Tray folder removed
- [ ] System tray icon gone

---

## 🍎 macOS Testing

### Phase 1: Verify Executable

```bash
# Check file exists and is reasonable size
ls -lh install-qz-tray-macos
# Should be ~51 MB

# Check if executable
file install-qz-tray-macos
# Should show ELF binary (application)
```

- [ ] File exists
- [ ] File size is ~51 MB
- [ ] Is executable (`chmod +x` if needed)

### Phase 2: Run Installer

1. **Download the executable**
2. **Open Terminal**
3. **Make executable:** `chmod +x ~/Downloads/install-qz-tray-macos`
4. **Run:** `~/Downloads/install-qz-tray-macos`
5. **When prompted for password:** Enter your macOS password
6. **Watch the installation:**
   - [ ] "QZ Tray Setup - Darwin" message appears
   - [ ] "Downloading QZ Tray..."
   - [ ] "Mounting and installing QZ Tray (macOS)..."
   - [ ] "Downloading certificate from..."
   - [ ] "✓ Certificate installed at..."
   - [ ] "Restarting QZ Tray..."
   - [ ] "✓ QZ Tray started"
   - [ ] "Setup Complete!" message

### Phase 3: Verify Installation

1. **Check menu bar:**
   - [ ] Printer icon appears (top-right)
   - [ ] Click → menu shows options

2. **Check file locations:**
   ```bash
   # Verify QZ Tray installed
   ls -la ~/Applications/QZ\ Tray.app
   # Should show the app bundle

   # Verify certificate installed
   cat ~/Library/Application\ Support/QZ\ Tray/override.crt | head -1
   # Should show: -----BEGIN CERTIFICATE-----
   ```

3. **Check running process:**
   ```bash
   ps aux | grep qz-tray
   # Should show qz-tray process running
   ```

### Phase 4: Test with ProString

1. **Open ProString** at `https://app.prostringmanage.com`
2. **Go to:** Settings → Printer Settings
3. **Check QZ connection:**
   - [ ] Green dot appears next to "QZ Tray: connected"
4. **Click "Reconnect":**
   - [ ] Printers appear in dropdowns
   - [ ] Can select receipt and label printers
5. **Test print:**
   - [ ] Create a simple order
   - [ ] Click print
   - [ ] Printer job sent without browser dialog
   - [ ] Check printer received the job

### Phase 5: Uninstall & Verify Cleanup

```bash
# Uninstall
rm -rf ~/Applications/QZ\ Tray.app
rm -rf ~/Library/Application\ Support/QZ\ Tray/

# Verify uninstalled
ls ~/Applications/QZ\ Tray.app 2>&1
# Should show: No such file or directory
```

- [ ] App removed
- [ ] Config folder removed
- [ ] Menu bar icon gone

---

## 🐧 Linux Testing

### Phase 1: Verify Executable

```bash
# Check file exists and is reasonable size
ls -lh install-qz-tray-linux
# Should be ~46 MB

# Check if executable
file install-qz-tray-linux
# Should show ELF binary
```

- [ ] File exists
- [ ] File size is ~46 MB
- [ ] Is executable (`chmod +x` if needed)

### Phase 2: Run Installer

1. **Download the executable**
2. **Open Terminal**
3. **Make executable:** `chmod +x ~/Downloads/install-qz-tray-linux`
4. **Run:** `~/Downloads/install-qz-tray-linux`
5. **When prompted for password:** Enter your sudo password
6. **Watch the installation:**
   - [ ] "QZ Tray Setup - Linux" message appears
   - [ ] "Downloading QZ Tray..."
   - [ ] "Installing QZ Tray (Linux)..."
   - [ ] Sees apt-get package installation
   - [ ] "Downloading certificate from..."
   - [ ] "✓ Certificate installed at..."
   - [ ] "Restarting QZ Tray..."
   - [ ] "✓ QZ Tray started"
   - [ ] "Setup Complete!" message

### Phase 3: Verify Installation

1. **Check running process:**
   ```bash
   ps aux | grep qz-tray
   # Should show qz-tray process running
   ```

2. **Check file locations:**
   ```bash
   # Verify QZ Tray installed
   ls -la /opt/qz-tray/qz-tray
   # Should show the executable

   # Verify certificate installed
   cat ~/.config/QZ\ Tray/override.crt | head -1
   # Should show: -----BEGIN CERTIFICATE-----
   ```

3. **Check system integration:**
   ```bash
   which qz-tray
   # Should show: /usr/local/bin/qz-tray or similar
   ```

### Phase 4: Test with ProString

1. **Open ProString** at `https://app.prostringmanage.com`
2. **Go to:** Settings → Printer Settings
3. **Check QZ connection:**
   - [ ] Green dot appears next to "QZ Tray: connected"
4. **Click "Reconnect":**
   - [ ] Printers appear in dropdowns
   - [ ] Can select receipt and label printers
5. **Test print:**
   - [ ] Create a simple order
   - [ ] Click print
   - [ ] Printer job sent without browser dialog
   - [ ] Check printer received the job

### Phase 5: Uninstall & Verify Cleanup

```bash
# Uninstall
sudo apt-remove qz-tray
# Or: sudo dpkg -r qz-tray

# Verify uninstalled
which qz-tray
# Should show: qz-tray not found
```

- [ ] Package removed
- [ ] Config folder removed
- [ ] No running process

---

## 📋 Cross-Platform Checklist

### Certificate Verification (All OS)

For each OS, verify the certificate matches:

```
Expected: https://prostringmanage.com/qz/override.crt
Content should start with: -----BEGIN CERTIFICATE-----
And contain: "ProString" subject
```

- [ ] Windows: `C:\Program Files\QZ Tray\override.crt`
- [ ] macOS: `~/Library/Application Support/QZ Tray/override.crt`
- [ ] Linux: `~/.config/QZ Tray/override.crt`

### Network/Connectivity (All OS)

- [ ] Installer can reach `https://qz.io/` (download QZ Tray)
- [ ] Installer can reach `https://prostringmanage.com/qz/override.crt`
- [ ] ProString can reach QZ Tray (green dot shows)
- [ ] ProString Settings page loads without errors

### Error Scenarios (All OS)

Test what happens when things fail:

1. **Disconnect internet during install:**
   - [ ] Error message is clear
   - [ ] Can retry
   - [ ] Cleanup happens (no partial installation)

2. **Wrong certificate URL:**
   - [ ] Installer fails gracefully
   - [ ] Error message explains certificate fetch failure

3. **Missing permissions:**
   - [ ] Windows: Clear message if not admin
   - [ ] macOS/Linux: Clear message if sudo fails

---

## ✅ Sign-Off Checklist

Before creating GitHub release:

- [ ] Windows: Install, verify, test with ProString, uninstall
- [ ] macOS: Install, verify, test with ProString, uninstall
- [ ] Linux: Install, verify, test with ProString, uninstall
- [ ] All 3 executables file sizes reasonable (~35-50 MB each)
- [ ] Certificate downloads correctly on all platforms
- [ ] Certificate path correct for each OS
- [ ] ProString shows green "connected" after "Reconnect"
- [ ] No error messages in ProString console
- [ ] Printers detected after install
- [ ] Print job sent without browser dialog

---

## 🚨 If Testing Fails

### Windows Issues

| Issue | Fix |
|-------|-----|
| "Setup Complete" but no QZ icon | Manually start: `C:\Program Files\QZ Tray\qz-tray.exe` |
| Certificate not found | Check: `C:\Program Files\QZ Tray\override.crt` exists |
| "Access Denied" | Must run as Administrator |
| Printers don't appear | Restart ProString after install |

### macOS Issues

| Issue | Fix |
|-------|-----|
| "Permission denied" running script | Run: `chmod +x install-qz-tray-macos` |
| Password prompt hangs | Try entering password and pressing Enter |
| Cannot open (unidentified developer) | System Settings → Privacy → Allow |
| Certificate not found | Check: `~/Library/Application Support/QZ Tray/override.crt` |

### Linux Issues

| Issue | Fix |
|-------|-----|
| dpkg errors | Run: `sudo apt-get install -f` |
| sudo password prompt | Enter your sudo password (characters won't show) |
| Process won't start | Check: `/opt/qz-tray/qz-tray` exists and is executable |
| Certificate not found | Check: `~/.config/QZ Tray/override.crt` |

---

## 📝 Testing Report Template

Use this to document your testing:

```
QZ Tray Installer Testing Report
Version: v1.0.0
Date: [TODAY]
Tester: [YOUR NAME]

WINDOWS
- [ ] File size: 37.6 MB ✓
- [ ] Installer runs: ✓
- [ ] QZ Tray installs: ✓
- [ ] Certificate placed: ✓
- [ ] ProString detects: ✓
- [ ] Print works: ✓
- [ ] Uninstall clean: ✓

macOS
- [ ] File size: 51.3 MB ✓
- [ ] Installer runs: ✓
- [ ] QZ Tray installs: ✓
- [ ] Certificate placed: ✓
- [ ] ProString detects: ✓
- [ ] Print works: ✓
- [ ] Uninstall clean: ✓

LINUX
- [ ] File size: 46.3 MB ✓
- [ ] Installer runs: ✓
- [ ] QZ Tray installs: ✓
- [ ] Certificate placed: ✓
- [ ] ProString detects: ✓
- [ ] Print works: ✓
- [ ] Uninstall clean: ✓

ISSUES FOUND: None
READY TO RELEASE: YES ✓
```

---

**Good luck with testing!** 🚀
