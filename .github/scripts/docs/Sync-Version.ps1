<#
.SYNOPSIS
    Syncs version headers across all PowerShell modules using the value from VERSION.txt.
.DESCRIPTION
    Reads the current version from VERSION.txt and updates the `.VERSION` header
    in each `.psm1` or `.ps1` file under the Modules folder. Supports dry-run mode and logs
    all actions to a specified folder.
.PARAMETER DryRun
    Simulates updates without modifying any files.
.PARAMETER LogPath
    Directory for log output. Defaults to Logs/CI/Docs/Version.
#>

param (
    [switch]$DryRun = $false,
    [string]$LogPath = "Logs/CI/Docs/Version"
)

# Ensure log directory exists
New-Item -ItemType Directory -Force -Path $LogPath | Out-Null
$logFile = Join-Path $LogPath "Sync-Version.log"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

"[$timestamp] Starting version sync..." | Out-File $logFile -Append

# Load version from VERSION.txt
try {
    $version = Get-Content VERSION.txt -ErrorAction Stop | Select-Object -First 1
    if (-not $version) {
        throw "VERSION.txt is empty or unreadable."
    }
    "[$timestamp] Loaded version: $version" | Out-File $logFile -Append
} catch {
    "[$timestamp] Failed to read VERSION.txt: $_" | Out-File $logFile -Append
    throw
}

# Target files: all .psm1 and .ps1 under Modules/
$files = Get-ChildItem -Path "Modules" -Recurse -Include *.psm1, *.ps1

foreach ($file in $files) {
    $content = Get-Content $file.FullName
    $newContent = @()
    $versionUpdated = $false

    foreach ($line in $content) {
        if ($line -match '^\s*#\s*\.VERSION\s*') {
            $newContent += "# .VERSION $version"
            $versionUpdated = $true
        } else {
            $newContent += $line
        }
    }

    if ($versionUpdated) {
        if ($DryRun) {
            "[$timestamp] DryRun: Would update version in $($file.FullName)" | Out-File $logFile -Append
        } else {
            $newContent | Set-Content $file.FullName
            "[$timestamp] Updated version in $($file.FullName)" | Out-File $logFile -Append
        }
    } else {
        "[$timestamp] No .VERSION header found in $($file.FullName)" | Out-File $logFile -Append
    }
}

"[$timestamp] Sync-Version.ps1 completed." | Out-File $logFile -Append
