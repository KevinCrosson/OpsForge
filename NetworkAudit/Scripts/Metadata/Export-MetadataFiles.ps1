<#
.SYNOPSIS
    Exports metadata to README.md and CHANGELOG.md.

.DESCRIPTION
    Converts metadata to markdown using ConvertToMarkdown.ps1 and writes it to documentation files.
    Supports dry-run mode and verbose output for CI/CD workflows.

.PARAMETER Metadata
    Hashtable of metadata to export.

.PARAMETER Root
    Root directory of the repository.

.PARAMETER DryRun
    Simulates export without writing files.

.PARAMETER Verbose
    Enables detailed output for logging and CI visibility.

.EXAMPLE
    Export-MetadataFiles -Metadata $Meta -Root "C:\.PS\NetworkAudit" -Verbose

.NOTES
    Dispatcher: Scripts/Dispatchers/Metadata/Export-MetadataFiles.ps1
#>

param (
    [Parameter(Mandatory = $true)]
    [hashtable]$Metadata,

    [Parameter(Mandatory = $true)]
    [string]$Root,

    [switch]$DryRun,
    [switch]$Verbose
)

# Import markdown converter
. "$Root\Scripts\Metadata\ConvertToMarkdown.ps1"

# Convert metadata to markdown
$Markdown = ConvertToMarkdown -Metadata $Metadata

# Define output paths
$ReadmePath    = Join-Path $Root "README.md"
$ChangelogPath = Join-Path $Root "CHANGELOG.md"

if ($DryRun) {
    Write-Host "[DryRun] Would write metadata to README.md and CHANGELOG.md" -ForegroundColor Yellow
    Write-Host $Markdown
    return
}

# Write markdown to README.md
Set-Content -Path $ReadmePath -Value $Markdown -Encoding UTF8

# Write markdown to CHANGELOG.md
Set-Content -Path $ChangelogPath -Value $Markdown -Encoding UTF8

if ($Verbose) {
    Write-Host "Metadata written to README.md and CHANGELOG.md" -ForegroundColor Green
}