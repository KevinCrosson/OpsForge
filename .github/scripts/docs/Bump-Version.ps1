<#
.SYNOPSIS
  Auto-increments the version in VERSION.txt (patch, minor, or major).

.PARAMETER Type
  The type of bump: patch (default), minor, or major.

.PARAMETER DryRun
  Simulates the version bump without writing to the file.
#>

param (
    [ValidateSet("patch", "minor", "major")]
    [string]$Type = "patch",

    [switch]$DryRun
)

$versionPath = "$PSScriptRoot\..\VERSION.txt"
if (-not (Test-Path $versionPath)) {
    Write-Error "VERSION.txt not found"
    exit 1
}

$current = Get-Content $versionPath | Select-Object -First 1
if ($current -notmatch "^v(\d+)\.(\d+)\.(\d+)$") {
    Write-Error "Invalid version format: $current"
    exit 1
}

$major, $minor, $patch = $matches[1..3] | ForEach-Object { [int]$_ }

switch ($Type) {
    "patch" { $patch++ }
    "minor" { $minor++; $patch = 0 }
    "major" { $major++; $minor = 0; $patch = 0 }
}

$newVersion = "v$major.$minor.$patch"

if ($DryRun) {
    Write-Host "DRY-RUN: Would bump version to $newVersion"
} else {
    $newVersion | Out-File $versionPath -Encoding UTF8
    Write-Host "VERSION.txt updated to $newVersion"
}
