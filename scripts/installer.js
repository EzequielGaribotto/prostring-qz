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

async function main() {
  try {
    if (platform === 'win32') {
      await installWindows()
    } else if (platform === 'darwin') {
      await installMacOS()
    } else if (platform === 'linux') {
      await installLinux()
    } else {
      console.error(`❌ Unsupported platform: ${platform}`)
      process.exit(1)
    }

  } catch (err) {
    console.error(`\n❌ Installation failed: ${err.message}\n`)
    process.exit(1)
  }
}

async function installWindows() {
  console.log('🪟 Windows Installation\n')

  try {
    execSync('net session', { stdio: 'ignore' })
  } catch (e) {
    console.error('❌ This script must be run as Administrator')
    console.error('   Right-click Command Prompt or PowerShell and select "Run as administrator"\n')
    process.exit(1)
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
      { stdio: 'inherit', shell: 'powershell.exe' }
    )
  } catch (err) {
    throw new Error('PowerShell installation failed')
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
  console.error(`\n❌ Error: ${err.message}\n`)
  process.exit(1)
})
