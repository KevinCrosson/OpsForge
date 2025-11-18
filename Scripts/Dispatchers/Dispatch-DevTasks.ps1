<#
.SYNOPSIS
  Task runner for orchestrating DevTasks in the NetworkAudit project.

.DESCRIPTION
  This script dispatches modular PowerShell scripts for cleanup, linting, metadata export,
  and changelog updates. It supports dry-run mode and is designed for local use or CI integration.

<#
.SYNOPSIS
  Task runner for orchestrating DevTasks in the NetworkAudit project.

.DESCRIPTION
  This script dispatches modular PowerShell scripts for cleanup, linting, metadata export,
  and changelog updates. It supports dry-run mode and is designed for local use or CI integration.

.PARAMETER Task
  The task to execute. Options:
    - cleanup   : Runs import path updates, broken import detection, and empty folder removal
    - lint      : Runs Markdown linter
    - metadata  : Exports README.md, VERSION.txt, and CHANGELOG.md
    - changelog : Appends a manual changelog entry

.PARAMETER DryRun
  If specified, all destructive actions are previewed but not executed.
#>

param (
    # Task selector with validation
    [ValidateSet("cleanup", "lint", "metadata", "changelog")]
    [string]$Task = "cleanup",

    # Optional dry-run flag to preview changes
    [switch]$DryRun = $false
)

# Resolve script root and DevTasks path
# This ensures the runner works regardless of where it's called from
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$devTasks = Join-Path $root "..\Modules\DevTasks\Scripts" | Resolve-Path | Select-Object -ExpandProperty Path
$releasePath = "$PSScriptRoot\..\Modules\DevTasks\Scripts\Release"

# Dispatch tasks based on user selection
switch ($Task) {

    "cleanup" {
        Write-Host "`n Running cleanup tasks..." -ForegroundColor Cyan

        # Step 1: Update Import Paths
        # Replaces legacy module paths with new structure
        & "$devTasks\Update-ImportPaths.ps1" -DryRun:$DryRun

        # Step 2: Detect and comment broken imports
        # Flags unresolved Import-Module statements and optionally comments them out
        & "$devTasks\Detect-BrokenImports.ps1" -DryRun:$DryRun

        # Step 3: Remove empty folders
        # Cleans up stale directories after refactor
        & "$devTasks\Delete-EmptyFolders.ps1" -DryRun:$DryRun

        # Step 4: Log changelog entry (only if not dry-run)
        if (-not $DryRun) {
            & "$devTasks\Write-ChangelogEntry.ps1" `
                -Message "Ran cleanup tasks: updated import paths, flagged broken imports, removed empty folders"
        }
    }

    "lint" {
        Write-Host "`n Running Markdown linter..." -ForegroundColor Cyan

        # Runs Markdown formatting checks before commit
        & "$devTasks\Lint-Markdown.ps1"
    }


"metadata" {
    Write-Host "`n Running metadata export and release prep..." -ForegroundColor Cyan

    # Step 1: Export metadata files
    & "$releasePath\Export-MetadataFiles.ps1"

    # Step 2: Bundle release archive
    & "$releasePath\Bundle-ReleaseArtifacts.ps1"

    # Step 3: Tag changelog with current version
    $version = Get-Content "$PSScriptRoot\VERSION.txt"
    & "$releasePath\Tag-Version.ps1" -Version $version

    # Step 4: Generate release notes
    & "$releasePath\Generate-ReleaseNotes.ps1"
}

    "changelog" {
        Write-Host "`n Writing manual changelog entry..." -ForegroundColor Cyan

        # Prompt user for changelog message interactively
        $msg = Read-Host "Enter changelog message"
        & "$devTasks\Write-ChangelogEntry.ps1" -Message $msg
    }

    default {
        Write-Host "Unknown task: $Task" -ForegroundColor Red
        exit 1
    }
}

# Final confirmation
Write-Host "`n Task '$Task' complete." -ForegroundColor Green
