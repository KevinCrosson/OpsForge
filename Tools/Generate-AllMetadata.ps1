<#
.SYNOPSIS
    Recursively generates or updates README.md, CHANGELOG.md, and VERSION.txt files across subdirectories.

.DESCRIPTION
    Supports dry-run previews, verbose logging, centralized audit tracking, and parameterized input for flexible reuse.

.PARAMETER RootDirs
    Array of root directories to scan recursively.

.PARAMETER DryRun
    If set, previews actions without writing files.

.PARAMETER Verbose
    If set, outputs detailed status messages.

.NOTES
    Author: Kevin Crosson
    Last Updated: 2025-11-10
#>

param (
    [string[]]$RootDirs = @("C:\BuildMate\NetworkAudit", "C:\BuildMate\Modules", "C:\BuildMate\Docs"),
    [switch]$DryRun,
    [switch]$Verbose
)

# Define default content templates
$DefaultReadme = @"
# Module Documentation

This folder contains scripts or documentation for a specific module. Please update this README with module-specific details.

## Overview
Describe the purpose and functionality of this module.

## Usage
Provide usage examples or instructions.

## Dependencies
List any required dependencies or prerequisites.

## Author
Kevin Crosson
"@

$DefaultChangelog = @"
# CHANGELOG

## [$(Get-Date -Format 'yyyy-MM-dd')] - Initial entry
- Created CHANGELOG.md for tracking updates.
"@

$DefaultVersion = "1.0.0"

# Define audit log path
$AuditLog = "C:\BuildMate\Logs\Metadata-Audit.log"
New-Item -Path $AuditLog -ItemType File -Force | Out-Null

# Function to log actions centrally
function Write-AuditLog {
    param ([string]$Message)
    Add-Content -Path $AuditLog -Value "$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss')) - $Message"
}

# Function to safely create or update a file
function Ensure-MetadataFile {
    param (
        [string]$Path,
        [string]$Content,
        [switch]$AppendIfExists
    )

    if (-Not (Test-Path $Path)) {
        if ($DryRun) {
            Write-Host "[DryRun] Would create: $Path"
            Write-AuditLog "DryRun: Would create $Path"
        } else {
            $Content | Out-File -FilePath $Path -Encoding UTF8
            Write-Host "Created: $Path"
            Write-AuditLog "Created: $Path"
        }
    }
    elseif ($AppendIfExists) {
        if ($DryRun) {
            Write-Host "[DryRun] Would append to: $Path"
            Write-AuditLog "DryRun: Would append to $Path"
        } else {
            "`n## [$(Get-Date -Format 'yyyy-MM-dd')] - Auto-update" | Out-File -FilePath $Path -Append -Encoding UTF8
            Write-Host "Updated: $Path"
            Write-AuditLog "Updated: $Path"
        }
    }
    else {
        if ($Verbose) {
            Write-Host "Exists: $Path"
            Write-AuditLog "Exists: $Path"
        }
    }
}

# Placeholder for future markdown linting
function Validate-Markdown {
    param ([string]$Path)
    # TODO: Add markdown linting logic here
    if ($Verbose) {
        Write-Host "Validated (placeholder): $Path"
        Write-AuditLog "Validated (placeholder): $Path"
    }
}

# Main loop to process each subdirectory
foreach ($Root in $RootDirs) {
    if (-Not (Test-Path $Root)) {
        Write-Host "Skipping missing root: $Root"
        Write-AuditLog "Skipped missing root: $Root"
        continue
    }

    Get-ChildItem -Path $Root -Directory -Recurse | ForEach-Object {
        $Folder = $_.FullName

        # Define metadata file paths
        $ReadmePath = Join-Path $Folder "README.md"
        $ChangelogPath = Join-Path $Folder "CHANGELOG.md"
        $VersionPath = Join-Path $Folder "VERSION.txt"

        # Create or update each file
        Ensure-MetadataFile -Path $ReadmePath -Content $DefaultReadme
        Validate-Markdown -Path $ReadmePath

        Ensure-MetadataFile -Path $ChangelogPath -Content $DefaultChangelog -AppendIfExists
        Validate-Markdown -Path $ChangelogPath

        Ensure-MetadataFile -Path $VersionPath -Content $DefaultVersion
    }
}

Write-Host "`nMetadata generation complete for all modules."
Write-AuditLog "Metadata generation complete."