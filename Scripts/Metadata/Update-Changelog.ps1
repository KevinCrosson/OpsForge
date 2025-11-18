<#
.SYNOPSIS
Appends a new version entry to CHANGELOG.md.

.DESCRIPTION
This script adds a timestamped changelog entry for the current version.
It supports dry-run mode and verbose logging, and is designed for use in CI/CD pipelines
or manual release workflows.

.EXAMPLE
Update-Changelog -Version "1.2.3" -OutputPath "CHANGELOG.md"
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$Version,

    [Parameter(Mandatory = $true)]
    [string]$OutputPath,

    [switch]$DryRun,
    [switch]$Verbose
)

# Log start
Write-Host "`n[+] Updating changelog..." -ForegroundColor Cyan
if ($DryRun) {
    Write-Host "[i] Dry-run mode enabled. No changes will be written." -ForegroundColor Yellow
}

# Step 1: Generate timestamp
$Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Step 2: Build changelog entry
$Entry = @()
$Entry += "## Version $Version"
$Entry += "**Released:** $Timestamp"
$Entry += ""
$Entry += "- Metadata updated"
$Entry += "- README regenerated"
$Entry += "- Version tags synced"
$Entry += ""

# Step 3: Preview or write to file
if ($DryRun) {
    Write-Host "`n[i] Changelog entry preview:" -ForegroundColor Yellow
    $Entry -join "`n" | Write-Output
    return $true
}

try {
    Add-Content -Path $OutputPath -Value ($Entry -join "`n")
    Write-Host "[Ã¢Å“â€œ] CHANGELOG.md updated with version $Version" -ForegroundColor Green
    return $true
} catch {
    Write-Error "Failed to update changelog: $_"
    return $false
}
