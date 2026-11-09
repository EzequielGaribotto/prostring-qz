# QZ Tray setup for ProString on Windows: installs QZ Tray (if missing), installs ProString's
# certificate (override.crt) and restarts QZ Tray.
#
# Options:
#   -CertificateUrl            certificate URL (default below)
#   $env:QZ_TRAY_VERSION       QZ Tray version to install (default below; a release of qzind/tray)
#   $env:QZ_SETUP_NONINTERACTIVE = 1   skip the final "press any key" pause (CI)
param(
    [string]$CertificateUrl = "https://prostringmanage.com/qz/override.crt"
)

$QzVersion = if ($env:QZ_TRAY_VERSION) { $env:QZ_TRAY_VERSION } else { "2.3.0" }
$QzArch = if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") { "arm64" } else { "x86_64" }

$ErrorActionPreference = "Stop"

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

# If not admin, restart with elevation
if (-not $isAdmin) {
    Write-Host "Requesting administrator privileges..." -ForegroundColor Yellow
    $scriptPath = $MyInvocation.MyCommand.Path
    $args = $MyInvocation.UnboundArguments

    if ($scriptPath) {
        Start-Process powershell.exe -Verb RunAs -ArgumentList @("-File", $scriptPath) + $args
    } else {
        Write-Host "Error: Unable to elevate privileges" -ForegroundColor Red
        exit 1
    }
    exit 0
}

Write-Host "QZ Tray Setup - Windows" -ForegroundColor Cyan

$qzTrayPath = "C:\Program Files\QZ Tray\qz-tray.exe"
if (-not (Test-Path $qzTrayPath)) {
    Write-Host "Downloading QZ Tray..." -ForegroundColor Yellow
    $tmpExe = "$env:TEMP\qz-tray-$QzVersion.exe"

    try {
        $web = New-Object System.Net.WebClient
        $web.DownloadFile("https://github.com/qzind/tray/releases/download/v$QzVersion/qz-tray-$QzVersion-$QzArch.exe", $tmpExe)
        Write-Host "Running installer..." -ForegroundColor Yellow
        Start-Process -FilePath $tmpExe -ArgumentList "/S" -Wait
        if (Test-Path $tmpExe) {
            Remove-Item $tmpExe -Force -ErrorAction SilentlyContinue
        }
        Write-Host "QZ Tray installed" -ForegroundColor Green
    } catch {
        Write-Host "Download failed: $_" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "QZ Tray already installed" -ForegroundColor Green
}

$certDir = "C:\Program Files\QZ Tray"
$certPath = "$certDir\override.crt"

if (-not (Test-Path $certDir)) {
    New-Item -ItemType Directory -Path $certDir -Force | Out-Null
}

Write-Host "Downloading certificate..." -ForegroundColor Yellow

try {
    $web = New-Object System.Net.WebClient
    $web.DownloadFile($CertificateUrl, $certPath)
    Write-Host "Certificate installed" -ForegroundColor Green
} catch {
    Write-Host "Certificate download failed: $_" -ForegroundColor Red
    exit 1
}

Write-Host "Restarting QZ Tray..." -ForegroundColor Yellow
Get-Process qz-tray -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

if (Test-Path $qzTrayPath) {
    & $qzTrayPath
    Write-Host "QZ Tray started" -ForegroundColor Green
}

Write-Host "`nSetup Complete!" -ForegroundColor Green
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. If QZ Tray shows a security dialog, click Allow" -ForegroundColor Gray
Write-Host "2. Configure printers in ProString Settings" -ForegroundColor Gray
if ($env:QZ_SETUP_NONINTERACTIVE -ne "1") {
    Write-Host "`nPress any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
