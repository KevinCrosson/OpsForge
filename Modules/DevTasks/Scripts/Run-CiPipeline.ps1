<#
.SYNOPSIS
    CI entry point for validating and exporting NetworkAudit metadata.
.DESCRIPTION
    Runs folder structure validation, version sync, metadata generation, Markdown export, linting, and changelog update.
.PARAMETER DryRun
    Simulates export without writing README.md or updating CHANGELOG.md.
#>

param (
    [switch]$DryRunCiPipline
)

$Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$LogPath = "$PSScriptRoot\..\Logs\CI-Pipeline.log"
"[$Timestamp] Starting CI pipeline (DryRun=$DryRun)" | Out-File $LogPath -Append

try {
    # Step 1: Validate folder structure
    & "$PSScriptRoot\Test-FolderStructure.ps1" -AutoFix
    "[$Timestamp] Folder structure validated." | Out-File $LogPath -Append

    # Step 2: Sync version across modules
    & "$PSScriptRoot\Sync-Version.ps1"
    "[$Timestamp] VERSION.txt synced across modules." | Out-File $LogPath -Append

    # Step 3: Generate metadata and export README + changelog
    & "$PSScriptRoot\Export-MetadataFiles.ps1" -DryRun:$DryRun
    "[$Timestamp] Metadata export complete." | Out-File $LogPath -Append

    # Step 4: Lint Markdown files
    & "$PSScriptRoot\Lint-Markdown.ps1"
    "[$Timestamp] Markdown linting passed." | Out-File $LogPath -Append

    Write-Host "` nCI pipeline completed successfully." -ForegroundColor Green
} catch {
    "[$Timestamp] CI pipeline failed: $_" | Out-File $LogPath -Append
    Write-Error "CI pipeline error: $_"
    exit 1
}
