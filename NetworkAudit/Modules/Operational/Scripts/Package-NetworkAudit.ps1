<#
.SYNOPSIS
    Packages NetworkAudit for release with versioning and changelog update.

.DESCRIPTION
    Compresses the bundle, updates VERSION.txt, appends to CHANGELOG.md, and optionally signs the archive.

.PARAMETER RootPath
    Base path of the NetworkAudit project

.PARAMETER DryRun
    Simulates packaging without writing files

.PARAMETER LogAudit
    Enables audit logging
#>

param (
    [string]$RootPath = "$PSScriptRoot\..\NetworkAudit",
    [switch]$DryRun,
    [switch]$Verbose,
    [switch]$LogAudit
)

$VersionFile = "$RootPath\VERSION.txt"
$Changelog   = "$RootPath\CHANGELOG.md"
$ReleaseDir  = "$RootPath\..\Releases"
$DateStamp   = Get-Date -Format "yyyyMMdd"
$Version     = Get-Content $VersionFile -Raw
$ZipName     = "NetworkAudit_v$Version_$DateStamp.zip"
$ZipPath     = Join-Path $ReleaseDir $ZipName

if ($DryRun) {
    Write-Host "DryRun: Would package to $ZipPath"
    return
}

# Ensure release directory exists
New-Item -ItemType Directory -Path $ReleaseDir -Force | Out-Null

# Create zip archive
Compress-Archive -Path "$RootPath\*" -DestinationPath $ZipPath -Force

# Append to changelog
$Entry = "## [$Version] - $(Get-Date -Format 'yyyy-MM-dd')`n- Release packaged as $ZipName`n"
Add-Content -Path $Changelog -Value "`n$Entry"

if ($LogAudit) {
    . "$RootPath\Modules\Write-AuditLog.psm1"
    Write-AuditLog -Action "PackageRelease" -Target $ZipPath -Details "Version $Version"
}

Write-Host "Packaged release: $ZipPath" -ForegroundColor Green
