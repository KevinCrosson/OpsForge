<#
.SYNOPSIS
Orchestrates metadata generation, README export, version syncing, and changelog updates for NetworkAudit.

.DESCRIPTION
This script invokes the full metadata pipeline:
1. Generates metadata from module headers and VERSION.txt.
2. Converts metadata to README.md using a Markdown template.
3. Syncs version tags across all scripts.
4. Updates CHANGELOG.md with the latest version and timestamp.

Supports dry-run mode, verbose logging, and CI integration.
#>

[CmdletBinding()]
param (
    [switch]$DryRun,
    [switch]$Verbose
)

# Resolve root directory relative to script location
$ScriptPath = $MyInvocation.MyCommand.Path
$Root = Split-Path -Path $ScriptPath -Parent | Split-Path -Parent

# Import local metadata tools from Scripts/Metadata
. "$Root\Scripts\Metadata\Generate-AllMetadata.ps1"
. "$Root\Scripts\Metadata\ConvertToMarkdown.ps1"
. "$Root\Scripts\Metadata\Sync-Version.ps1"
. "$Root\Scripts\Metadata\Update-Changelog.ps1"

# Log start of operation
Write-Host "`n[+] Starting metadata export process..." -ForegroundColor Cyan
if ($DryRun) {
    Write-Host "[i] Dry-run mode enabled. No files will be modified." -ForegroundColor Yellow
}

# Step 1: Generate metadata from VERSION.txt and module headers
Write-Host "`n[1] Generating metadata..." -ForegroundColor Green
$Metadata = Generate-AllMetadata -Root $Root -DryRun:$DryRun -Verbose:$Verbose

if (-not $Metadata) {
    Write-Error "Metadata generation failed. Aborting."
    exit 1
}

# Step 2: Convert metadata to README.md using Markdown template
Write-Host "`n[2] Exporting README.md..." -ForegroundColor Green
$ReadmePath = Join-Path -Path $Root -ChildPath "README.md"
ConvertTo-Markdown -Metadata $Metadata -OutputPath $ReadmePath -DryRun:$DryRun -Verbose:$Verbose

# Step 3: Sync version tags across all modules
Write-Host "`n[3] Syncing version tags..." -ForegroundColor Green
Sync-Version -Root $Root -Version $Metadata.Version -DryRun:$DryRun -Verbose:$Verbose

# Step 4: Update CHANGELOG.md with timestamp and version
Write-Host "`n[4] Updating CHANGELOG.md..." -ForegroundColor Green
$ChangelogPath = Join-Path -Path $Root -ChildPath "CHANGELOG.md"
Update-Changelog -Version $Metadata.Version -OutputPath $ChangelogPath -DryRun:$DryRun -Verbose:$Verbose

# Final status
Write-Host "`n[Ã¢Å“â€œ] Metadata export process complete." -ForegroundColor Cyan
if ($DryRun) {
    Write-Host "[i] No changes were made due to dry-run mode." -ForegroundColor Yellow
}
