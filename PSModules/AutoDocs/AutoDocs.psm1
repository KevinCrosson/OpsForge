<#
.SYNOPSIS
    AutoDocs PowerShell Module

.DESCRIPTION
    Provides reusable functions for automated documentation generation:
    - README generation from template
    - CHANGELOG update
    - VERSION bumping
    - LICENSE copying
    - Full bundling dispatcher

    Designed for use both locally and in CI/CD workflows.
#>

# ------------------------------------------------------------
# Function: Invoke-ReadmeGeneration
# ------------------------------------------------------------
# Purpose:
#   Reads Docs\README.Template.md and replaces placeholders
#   with live values (Version, Date, Changelog, License).
# Usage:
#   Invoke-ReadmeGeneration
# ------------------------------------------------------------
function Invoke-ReadmeGeneration {
    Write-Output "📝 Generating README.md from template..."

    $templatePath = Join-Path $PSScriptRoot "Docs\README.Template.md"
    $outputPath   = Join-Path $PSScriptRoot "README.md"

    if (-not (Test-Path $templatePath)) {
        Write-Error "Template file not found: $templatePath"
        return
    }

    $template  = Get-Content $templatePath -Raw
    $version   = Get-Content (Join-Path $PSScriptRoot "Docs\VERSION") -Raw
    $date      = (Get-Date).ToString("yyyy-MM-dd HH:mm")
    $changelog = Get-Content (Join-Path $PSScriptRoot "Docs\CHANGELOG.md") -Raw
    $license   = Get-Content (Join-Path $PSScriptRoot "Docs\LICENSE") -Raw

    # Replace placeholders
    $template = $template -replace "{{Version}}", $version.Trim()
    $template = $template -replace "{{Date}}", $date
    $template = $template -replace "{{Changelog}}", $changelog
    $template = $template -replace "{{License}}", $license

    Set-Content -Path $outputPath -Value $template -Encoding UTF8

    Write-Output "✅ README.md generated successfully."
}

# ------------------------------------------------------------
# Function: Invoke-ChangelogUpdate
# ------------------------------------------------------------
# Purpose:
#   Appends a new entry to Docs\CHANGELOG.md when version changes.
# Usage:
#   Invoke-ChangelogUpdate -Version "1.0.1"
# ------------------------------------------------------------
function Invoke-ChangelogUpdate {
    param(
        [string]$Version = (Get-Content (Join-Path $PSScriptRoot "Docs\VERSION") -Raw).Trim()
    )

    Write-Output "📜 Updating CHANGELOG.md for version $Version..."

    $changelogPath = Join-Path $PSScriptRoot "Docs\CHANGELOG.md"
    $entry = "## v$Version - $(Get-Date -Format 'yyyy-MM-dd HH:mm')`n- Automated entry"

    Add-Content -Path $changelogPath -Value $entry

    Write-Output "✅ CHANGELOG.md updated."
}

# ------------------------------------------------------------
# Function: Invoke-VersionBump
# ------------------------------------------------------------
# Purpose:
#   Bumps semantic version (Major, Minor, Patch).
# Usage:
#   Invoke-VersionBump -Bump Patch
# ------------------------------------------------------------
function Invoke-VersionBump {
    param(
        [ValidateSet("Major","Minor","Patch")]
        [string]$Bump = "Patch"
    )

    Write-Output "🔢 Bumping version ($Bump)..."

    $versionPath = Join-Path $PSScriptRoot "Docs\VERSION"
    $current     = (Get-Content $versionPath -Raw).Trim()
    $parts       = $current.Split(".")

    if ($parts.Count -ne 3) {
        Write-Error "VERSION must be in format x.y.z"
        return
    }

    $major = [int]$parts[0]
    $minor = [int]$parts[1]
    $patch = [int]$parts[2]

    switch ($Bump) {
        "Major" { $major++; $minor = 0; $patch = 0 }
        "Minor" { $minor++; $patch = 0 }
        "Patch" { $patch++ }
    }

    $newVersion = "$major.$minor.$patch"
    Set-Content -Path $versionPath -Value $newVersion -Encoding UTF8

    Write-Output "✅ Version bumped to $newVersion"
}

# ------------------------------------------------------------
# Function: Invoke-LicenseCopy
# ------------------------------------------------------------
# Purpose:
#   Copies LICENSE file into Docs folder for bundling.
# Usage:
#   Invoke-LicenseCopy
# ------------------------------------------------------------
function Invoke-LicenseCopy {
    Write-Output "⚖️ Copying LICENSE into Docs..."

    $licenseSrc  = Join-Path $PSScriptRoot "LICENSE"
    $licenseDest = Join-Path $PSScriptRoot "Docs\LICENSE"

    if (-not (Test-Path $licenseSrc)) {
        Write-Error "LICENSE file not found at $licenseSrc"
        return
    }

    Copy-Item $licenseSrc $licenseDest -Force

    Write-Output "✅ LICENSE copied successfully."
}

# ------------------------------------------------------------
# Function: Invoke-BundleDocs
# ------------------------------------------------------------
# Purpose:
#   Orchestrates all documentation tasks:
#   - README generation
#   - CHANGELOG update
#   - VERSION bump
#   - LICENSE copy
# Usage:
#   Invoke-BundleDocs
# ------------------------------------------------------------
function Invoke-BundleDocs {
    Write-Output "📦 Bundling documentation for release..."

    Invoke-ReadmeGeneration
    Invoke-ChangelogUpdate
    Invoke-VersionBump
    Invoke-LicenseCopy

    Write-Output "✅ Documentation bundle complete."
}
