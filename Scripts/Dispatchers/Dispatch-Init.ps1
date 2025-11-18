<#
.SYNOPSIS
    Bootstraps DevRunner folder structure and metadata files.

.DESCRIPTION
    Creates required folders, initializes VERSION.txt, and optionally runs Export-MetadataFiles.ps1.

.PARAMETER RunMetadata
    If specified, runs metadata export after bootstrapping.

.AUTHOR
    Kevin Crosson
#>

param (
    [switch]$RunMetadata
)

$RepoRoot = git rev-parse --show-toplevel
$folders = @(
    "Logs/Dispatch",
    "Logs/Release",
    "Modules/DevTasks/Scripts",
    "DevRunner/Scripts/Release",
    "DevRunner/Scripts/Dispatch"
)

Write-Host "`n Bootstrapping DevRunner folders..." -ForegroundColor Cyan

foreach ($folder in $folders) {
    $path = Join-Path $RepoRoot $folder
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
        Write-Host " - Created: $folder"
    } else {
        Write-Host " - Exists: $folder"
    }
}

# Initialize VERSION.txt
$versionFile = Join-Path $RepoRoot "VERSION.txt"
if (-not (Test-Path $versionFile)) {
    "0.1.0" | Set-Content $versionFile
    Write-Host " - Initialized VERSION.txt with 0.1.0"
} else {
    Write-Host " - VERSION.txt already exists"
}

# Optionally run metadata export
if ($RunMetadata) {
    $exportScript = Join-Path $RepoRoot "DevRunner\Scripts\Release\Export-MetadataFiles.ps1"
    if (Test-Path $exportScript) {
        & $exportScript
        Write-Host "Metadata export complete."
    } else {
        Write-Warning "Export-MetadataFiles.ps1 not found."
    }
}
