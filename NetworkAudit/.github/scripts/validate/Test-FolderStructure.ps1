<#
.SYNOPSIS
    Validates required folder and file structure for NetworkAudit.
.DESCRIPTION
    Checks for missing paths and optionally creates missing folders.
.PARAMETER AutoFix
    Creates missing folders if they don't exist.
#>

param (
    [switch]$AutoFix
)

$RootPath = Resolve-Path "$PSScriptRoot\.."
$RequiredPaths = @(
    "$RootPath\Modules",
    "$RootPath\Scripts",
    "$RootPath\Docs",
    "$RootPath\Diagrams",
    "$RootPath\Modules\Operational\Functions\Generate-AllMetadata.psm1",
    "$RootPath\Modules\Operational\Functions\ConvertToMarkdown.psm1"
)

$Missing = @()

foreach ($Path in $RequiredPaths) {
    if (-not (Test-Path $Path)) {
        $Missing += $Path
        Write-Host "Missing: $Path" -ForegroundColor Red
        if ($AutoFix -and ($Path -notmatch '\.psm1$')) {
            New-Item -ItemType Directory -Path $Path -Force | Out-Null
            Write-Host "Created folder: $Path" -ForegroundColor Yellow
        }
    } else {
        Write-Host "Found: $Path" -ForegroundColor Green
    }
}

if ($Missing.Count -eq 0) {
    Write-Host "`n Folder structure is valid." -ForegroundColor Cyan
} else {
    Write-Host "`n Validation failed. Missing paths: $($Missing.Count)" -ForegroundColor Magenta
    exit 1
}

