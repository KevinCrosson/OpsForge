<#
.SYNOPSIS
    Bundles all documentation files for release.

.DESCRIPTION
    - Generates README.md from Docs\README.template.md
    - Updates Docs\CHANGELOG.md and copies it to root
    - Bumps Docs\VERSION and copies it to root
    - Copies LICENSE into Docs\LICENSE.txt
    - Logs results for CI/CD and contributor onboarding
#>

Write-Output "📦 Bundling documentation for release..."

# --- Setup paths ---
$Root    = (Get-Location).Path
$DocsDir = Join-Path $Root "Docs"
$LogDir  = Join-Path $Root "Scripts\Maintenance\Logs"

# Ensure required folders exist
if (-not (Test-Path $DocsDir)) { New-Item -ItemType Directory -Path $DocsDir | Out-Null }
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir | Out-Null }

$LogFile = Join-Path $LogDir "DocsBundle.log"

try {
    # --- README ---
    Write-Output "📝 Generating README..."
    & Scripts\Metadata\Generate-README.ps1

    # --- CHANGELOG ---
    Write-Output "📜 Updating Changelog..."
    & Scripts\Metadata\Generate-Changelog.ps1

    # --- VERSION ---
    Write-Output "🔢 Bumping Version..."
    & Scripts\Metadata\Generate-Version.ps1

    # --- LICENSE ---
    Write-Output "⚖️ Copying License..."
    if (Test-Path LICENSE) {
        Copy-Item LICENSE $DocsDir\LICENSE.txt -Force
    } else {
        throw "LICENSE file not found at repo root!"
    }

    # --- Log success ---
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFile -Value "[$Timestamp] Documentation bundle completed successfully."
    Write-Output "✅ Documentation bundle complete."
}
catch {
    # --- Log failure ---
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFile -Value "[$Timestamp] Documentation bundle failed: $_"
    Write-Error "❌ Documentation bundle failed: $_"
    exit 1
}

