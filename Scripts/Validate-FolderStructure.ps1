<#
.SYNOPSIS
    Validates required folder structure and key files for NetworkAudit release.

.DESCRIPTION
    Ensures all critical directories and files exist before packaging. Logs issues if any are missing.

.PARAMETER RootPath
    Base path to validate (defaults to NetworkAudit root)

.NOTES
    Author: Kevin Crosson
#>

param (
    [string]$RootPath = "$PSScriptRoot\..\NetworkAudit",
    [switch]$Verbose
)

$RequiredPaths = @(
    "$RootPath\Modules",
    "$RootPath\Scripts",
    "$RootPath\Docs",
    "$RootPath\Diagrams",
    "$RootPath\Modules\Generate-AllMetadata.psm1",
    "$RootPath\Modules\ConvertToMarkdown.psm1"
)

$Missing = @()

foreach ($Path in $RequiredPaths) {
    if (-not (Test-Path $Path)) {
        $Missing += $Path
        Write-Warning "Missing: $Path"
    } elseif ($Verbose) {
        Write-Host "Found: $Path"
    }
}

if ($Missing.Count -gt 0) {
    throw "Folder structure validation failed. Missing paths: $($Missing -join ', ')"
} else {
    Write-Host "Folder structure is valid." -ForegroundColor Green
}