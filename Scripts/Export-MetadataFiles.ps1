<#
.SYNOPSIS
    Wrapper script to auto-generate .md and .txt metadata files from Generate-AllMetadata.psm1 across NetworkAudit/

.DESCRIPTION
    Recursively invokes Generate-AllMetadata.psm1 on each target folder, exporting results to Markdown and plain text.
    Supports dry-run, verbose output, and centralized audit logging.

.NOTES
    Author: Kevin Crosson
    Module: NetworkAudit
    Dependencies: Generate-AllMetadata.psm1, Write-AuditLog.ps1 (optional)
#>

param (
    [string]$RootPath = "$PSScriptRoot\NetworkAudit",
    [switch]$DryRun,
    [switch]$Verbose,
    [switch]$LogAudit
)

# Import the metadata generation module
Import-Module "$PSScriptRoot\Modules\Generate-AllMetadata.psm1" -Force

# Optional: Import audit logging if enabled
if ($LogAudit) {
    . "$PSScriptRoot\Modules\Write-AuditLog.ps1"
}

# Recursively find all folders under NetworkAudit/
$TargetFolders = Get-ChildItem -Path $RootPath -Directory -Recurse

foreach ($Folder in $TargetFolders) {
    $FolderPath = $Folder.FullName
    $FolderName = $Folder.Name

    if ($Verbose) {
        Write-Host "Processing folder: $FolderPath"
    }

    # Generate metadata object
    $Metadata = Get-AllMetadata -Path $FolderPath

    if ($DryRun) {
        Write-Host "DryRun: Metadata for $FolderName would be written to .md and .txt"
        continue
    }

    # Define output paths
    $MarkdownPath = Join-Path $FolderPath "$FolderName.metadata.md"
    $TextPath     = Join-Path $FolderPath "$FolderName.metadata.txt"

    # Convert metadata to Markdown and plain text
    $MarkdownContent = $Metadata | ConvertTo-Markdown
    $TextContent     = $Metadata | Out-String

    # Write to files
    $MarkdownContent | Set-Content -Path $MarkdownPath -Encoding UTF8
    $TextContent     | Set-Content -Path $TextPath -Encoding UTF8

    if ($LogAudit) {
        Write-AuditLog -Action "MetadataExport" -Target $FolderPath -Details "Generated .md and .txt"
    }
}