#!/usr/bin/env node

const { execSync } = require('child_process')
const { writeFileSync, readFileSync } = require('fs')
const path = require('path')
const os = require('os')

const platform = os.platform()
const arch = os.arch()

console.log('\n╔═══════════════════════════════════════════╗')
console.log('║     QZ Tray Setup Wizard for ProString    ║')
console.log('╚═══════════════════════════════════════════╝\n')

console.log(`Platform: ${platform} (${arch})`)
console.log(`Node.js: ${process.version}\n`)

// Every failure ends here: the window stays open with what went wrong and what to do next. Double-clicked, the
// installer runs in its own console window, which used to close at once on an error (a user saw the terminal open
// and close, with QZ Tray not installed).
function fail(message) {
  console.error(`\n❌ QZ Tray was NOT installed: ${message}\n`)
  console.error('What to do:')
  console.error('  1. Take a screenshot of this window and send it to ProString support.')
  console.error('  2. Or install it by hand: in ProString, Settings > Printer > Install QZ Tray > manual installation.')
  console.error('     Steps also at https://github.com/EzequielGaribotto/prostring-qz#-manual-installation-no-installer-at-all\n')
  if (platform === 'win32' && process.env.QZ_SETUP_NONINTERACTIVE !== '1') {
    try { execSync('pause', { stdio: 'inherit', shell: 'cmd.exe' }) } catch { /* no console */ }
  }
  process.exit(1)
}

async function main() {
  try {
    if (platform === 'win32') {
      await installWindows()
    } else if (platform === 'darwin') {
      await installMacOS()
    } else if (platform === 'linux') {
      await installLinux()
    } else {
      fail(`unsupported system: ${platform}`)
    }

  } catch (err) {
    fail(err.message)
  }
}

async function installWindows() {
  console.log('🪟 Windows Installation\n')

  try {
    execSync('net session', { stdio: 'ignore' })
  } catch (e) {
    fail('the installer needs administrator rights. Right-click install-qz-tray-win.exe and choose "Run as administrator".')
  }

  console.log('Running PowerShell installer...\n')

  // The script ships inside the executable (pkg asset); a copy of it used to be embedded as base64
  // and had drifted from qz-tray-setup.ps1.
  const scriptContent = readFileSync(path.join(__dirname, 'qz-tray-setup.ps1'), 'utf-8')
  const scriptPath = path.join(os.tmpdir(), 'qz-tray-setup.ps1')
  const windowsLineEndings = scriptContent.replace(/\n/g, '\r\n')
  writeFileSync(scriptPath, windowsLineEndings, 'utf-8')

  try {
    execSync(
      `powershell -ExecutionPolicy Bypass -File "${scriptPath}"`,
      // This window pauses on its own (fail() or the end below): the script must not wait for a key too.
      { stdio: 'inherit', shell: 'powershell.exe', env: { ...process.env, QZ_SETUP_NONINTERACTIVE: '1' } }
    )
  } catch (err) {
    throw new Error('the setup script stopped (its message is above)')
  }

  console.log('\nPress any key to exit...')
  execSync('pause', { shell: 'cmd.exe' })
}

async function installMacOS() {
  console.log('🍎 macOS Installation\n')
  console.log('Running shell installer...\n')

  const scriptPath = path.join(__dirname, 'qz-tray-setup.sh')

  try {
    execSync(`bash "${scriptPath}"`, { stdio: 'inherit' })
  } catch (err) {
    throw new Error('Shell installation failed')
  }
}

async function installLinux() {
  console.log('🐧 Linux Installation\n')
  console.log('Running shell installer...\n')

  const scriptPath = path.join(__dirname, 'qz-tray-setup.sh')

  try {
    execSync(`bash "${scriptPath}"`, { stdio: 'inherit' })
  } catch (err) {
    throw new Error('Shell installation failed')
  }
}

main().catch((err) => {
  fail(err.message)
})
