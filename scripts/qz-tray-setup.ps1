# QZ Tray setup for ProString on Windows: installs QZ Tray (if missing), installs ProString's
# certificate (override.crt) and restarts QZ Tray.
#
# Options:
#   -CertificateUrl            certificate URL (default below)
#   $env:QZ_TRAY_VERSION       QZ Tray release tag to install (default below; a release of qzind/tray)
#   $env:QZ_TRAY_BUILD         version in that release's file names (QZ re-published 2.3.0 as "2.3.0+1")
#   $env:QZ_ALLOW_UNPINNED = 1 install a file with no pinned checksum below (testing only)
#   $env:QZ_SETUP_NONINTERACTIVE = 1   skip the final "press any key" pause (CI)
param(
    [string]$CertificateUrl = "https://prostringmanage.com/qz/override.crt"
)

$QzVersion = if ($env:QZ_TRAY_VERSION) { $env:QZ_TRAY_VERSION } else { "2.3.0" }
$QzBuild = if ($env:QZ_TRAY_BUILD) { $env:QZ_TRAY_BUILD } elseif ($QzVersion -eq "2.3.0") { "2.3.0+1" } else { $QzVersion }
$QzArch = if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") { "arm64" } else { "x86_64" }

# The installer runs as administrator: each file must match the SHA-256 GitHub publishes for it
# (gh release view v<version> -R qzind/tray --json assets). A new QZ version or re-published file needs its line here.
$PinnedSha256 = @{
    "qz-tray-2.3.0+1-x86_64.exe" = "01a8ae33da31c78f386ef8335024723f2dd2cb7d8bc44ce33079bf6bc0360011"
    "qz-tray-2.3.0+1-arm64.exe"  = "76ce2e492779589e2a61697344ba0b871ec8ec67942c9e08c5a1c9d90f5119c5"
}
# SHA-256 fingerprint of ProString's certificate (https://prostringmanage.com/qz/override.crt, valid until 2046).
$CertSha256 = "cb277265a6afb2536c87c6ca76bf44da63ecb6dd1ba99d0c40ef980bbdcfda04"

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
    $file = "qz-tray-$QzBuild-$QzArch.exe"
    $expected = $PinnedSha256[$file]
    if (-not $expected -and $env:QZ_ALLOW_UNPINNED -ne "1") {
        Write-Host "No pinned checksum for $($file): refusing to install it." -ForegroundColor Red
        exit 1
    }
    Write-Host "Downloading QZ Tray $QzBuild ($file)..." -ForegroundColor Yellow
    $tmpExe = Join-Path $env:TEMP ("qz-tray-" + [guid]::NewGuid().ToString("N") + ".exe")

    try {
        $web = New-Object System.Net.WebClient
        $web.DownloadFile("https://github.com/qzind/tray/releases/download/v$QzVersion/" + $file.Replace("+", "%2B"), $tmpExe)
        if ($expected) {
            $actual = (Get-FileHash -Algorithm SHA256 -Path $tmpExe).Hash.ToLower()
            if ($actual -ne $expected) {
                Remove-Item $tmpExe -Force -ErrorAction SilentlyContinue
                Write-Host "Checksum mismatch for $($file): expected $expected, got $actual. Not installing." -ForegroundColor Red
                exit 1
            }
            Write-Host "Checksum OK" -ForegroundColor Green
        }
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

$tmpCert = Join-Path $env:TEMP ("override-" + [guid]::NewGuid().ToString("N") + ".crt")
try {
    $web = New-Object System.Net.WebClient
    $web.DownloadFile($CertificateUrl, $tmpCert)
} catch {
    Write-Host "Certificate download failed: $_" -ForegroundColor Red
    exit 1
}
# Only ProString's own certificate is accepted from the default address (its SHA-256 fingerprint).
if ($CertificateUrl -eq "https://prostringmanage.com/qz/override.crt") {
    try {
        $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList $tmpCert
        $sha = [System.Security.Cryptography.SHA256]::Create()
        $fp = -join ($sha.ComputeHash($cert.RawData) | ForEach-Object { $_.ToString("x2") })
    } catch { $fp = "" }
    if ($fp -ne $CertSha256) {
        Remove-Item $tmpCert -Force -ErrorAction SilentlyContinue
        Write-Host "The downloaded certificate is not ProString's certificate. Not installing it." -ForegroundColor Red
        exit 1
    }
}
Move-Item -Path $tmpCert -Destination $certPath -Force
Write-Host "Certificate installed" -ForegroundColor Green

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
