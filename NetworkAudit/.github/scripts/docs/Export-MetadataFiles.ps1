<#
.SYNOPSIS
    Export metadata files for NetworkAudit modules, including README.md, VERSION.txt, and CHANGELOG.md.

.DESCRIPTION
    This script orchestrates metadata generation, Markdown export, version syncing, and changelog updates.
    It also copies VERSION.txt and CHANGELOG.md from the DevRunner folder into the metadata output directory.

.PARAMETER DryRun
    Simulates actions without writing files.

.AUTHOR
    Kevin Crosson

.TAGS
    Metadata, Export, Changelog, Versioning, CI
#>

param (
    [switch]$DryRun
)

# --- Resolve base path ---
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path

# --- Define relative paths from $Root ---
$outputDir       = Join-Path $Root "..\..\Docs\Metadata"
$functionsPath   = Join-Path $Root "..\..\Modules\Functions"
$devRunnerPath   = Join-Path $Root "..\..\DevRunner"
$versionFile     = Join-Path $devRunnerPath "VERSION.txt"
$changelogFile   = Join-Path $devRunnerPath "CHANGELOG.md"

# --- Load helper functions if present ---
if (Test-Path $functionsPath) {
    Get-ChildItem -Path $functionsPath -Filter *.ps1 | ForEach-Object {
        $_.FullName
    }
}

# --- Generate metadata ---
Write-Host "`Generating metadata..." -ForegroundColor Cyan
$metadata = Generate-AllMetadata

# --- Export README.md ---
$readme = ConvertToMarkdown -Metadata $metadata
$readmePath = Join-Path $outputDir "README.md"
if (-not $DryRun) {
    $readme | Out-File $readmePath -Encoding UTF8
    Write-Host "README.md written to $readmePath"
} else {
    Write-Host "DRY-RUN: Would write README.md to $readmePath"
}

# --- Sync VERSION.txt ---
$version = $metadata.Version
$versionPath = Join-Path $outputDir "VERSION.txt"
if (-not $DryRun) {
    $version | Out-File $versionPath -Encoding UTF8
    Write-Host "VERSION.txt written to $versionPath"
} else {
    Write-Host "DRY-RUN: Would write VERSION.txt to $versionPath"
}

# --- Update CHANGELOG.md ---
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$entry = "Exported metadata for version $version at $timestamp"
if (-not $DryRun) {
    Update-Changelog -Message $entry
    Write-Host "CHANGELOG.md updated with entry: $entry"
} else {
    Write-Host "DRY-RUN: Would update CHANGELOG.md with entry: $entry"
}

# --- Copy DevRunner version/changelog ---
if (Test-Path $versionFile) {
    Copy-Item $versionFile $versionPath -Force
    Write-Host "Copied VERSION.txt from DevRunner"
} else {
    Write-Warning "VERSION.txt not found in DevRunner"
}

if (Test-Path $changelogFile) {
    Copy-Item $changelogFile (Join-Path $outputDir "CHANGELOG.md") -Force
    Write-Host "Copied CHANGELOG.md from DevRunner"
} else {
    Write-Warning "CHANGELOG.md not found in DevRunner"
}

Write-Host "Metadata export complete." -ForegroundColor Green
