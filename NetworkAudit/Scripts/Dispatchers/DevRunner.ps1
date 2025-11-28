<#
.SYNOPSIS
    Dispatcher script for running modular tasks in NetworkAudit.

.DESCRIPTION
    Executes named tasks such as metadata generation, changelog updates, and diagnostics.
    Supports dry-run and verbose flags for CI/CD integration.

.PARAMETER Task
    Name of the task to run (e.g., "Update-Metadata", "Update-Changelog").

.PARAMETER DryRun
    Simulates execution without writing files.

.PARAMETER Verbose
    Enables detailed output.

.EXAMPLE
    .\DevRunner.ps1 -Task "Update-Metadata" -Verbose

.NOTES
    Location: Scripts/Dispatchers/DevRunner.ps1
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$Task,

    [switch]$DryRun,
    [switch]$Verbose
)

# Resolve repo root
$Root = (Get-Location).Path

# Dispatcher logic
switch ($Task) {

    "Update-Metadata" {
        . "$Root\Scripts\Dispatchers\Metadata\Run-Metadata.ps1"
        Run-Metadata -Root $Root -DryRun:$DryRun -Verbose:$Verbose
        break
    }

    "Update-Changelog" {
        . "$Root\Scripts\Metadata\Update-Changelog.ps1"
        Update-Changelog -Version "1.3.0" `
                         -Notes @("Updated metadata pipeline", "Exported JSON for dashboard") `
                         -OutputPath "$Root\CHANGELOG.md" `
                         -DryRun:$DryRun -Verbose:$Verbose
        break
    }

    "Sync-Metadata" {
        . "$Root\Scripts\Dispatchers\Metadata\Sync-Metadata.ps1"
        Sync-Metadata -Root $Root -Verbose:$Verbose
        break
    }

    default {
        Write-Warning "Unknown task: $Task"
        Write-Host "Available tasks: Update-Metadata, Update-Changelog, Sync-Metadata"
    }
}
