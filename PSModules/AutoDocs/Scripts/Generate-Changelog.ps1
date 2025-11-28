<#
.SYNOPSIS
    Updates Docs\CHANGELOG.md with the current version.

.DESCRIPTION
    - Reads Docs\VERSION
    - Appends a new entry to Docs\CHANGELOG.md
    - Copies updated file to root CHANGELOG.md
#>

$Root          = (Get-Location).Path
$ChangelogPath = Join-Path $Root "Docs\CHANGELOG.md"
$OutputPath    = Join-Path $Root "CHANGELOG.md"
$VersionPath   = Join-Path $Root "Docs\VERSION"

# Read current version
if (-not (Test-Path $VersionPath)) {
    Write-Error "VERSION file not found at $VersionPath"
    exit 1
}
$version   = (Get-Content $VersionPath -Raw).Trim()
$timestamp = Get-Date -Format "yyyy-MM-dd"

# Build new changelog entry
$newEntry = @"
## [$version] - $timestamp
### Changed
- Automated changelog entry for version $version
"@

# Append entry to Docs\CHANGELOG.md
Add-Content -Path $ChangelogPath -Value $newEntry

# Copy to root for GitHub visibility
Copy-Item $ChangelogPath $OutputPath -Force

Write-Output "✅ CHANGELOG.md updated successfully."