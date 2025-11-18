<#
.SYNOPSIS
    Tags the Git repository using the version in VERSION.txt and appends a timestamped entry to CHANGELOG.md.
.DESCRIPTION
    This script reads the version number from VERSION.txt, creates a Git tag (vX.Y.Z),
    pushes it to the origin, and appends a standardized entry to CHANGELOG.md.
    It supports dry-run mode and logs all actions to a specified folder.
.PARAMETER DryRun
    If specified, the script will simulate actions without modifying the repo or changelog.
.PARAMETER LogPath
    Directory where log output will be written. Defaults to Logs/CI/Release/Tag.
#>

param (
    [switch]$DryRun = $false,
    [string]$LogPath = "Logs/CI/Release/Tag"
)

# Ensure the log directory exists
New-Item -ItemType Directory -Force -Path $LogPath | Out-Null
$logFile = Join-Path $LogPath "Tag-Version.log"

# Timestamp for logging and changelog entry
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Read version from VERSION.txt
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

# Create and push Git tag
$tagName = "$version"
if ($DryRun) {
    "[$timestamp] DryRun: Would run 'git tag $tagName'" | Out-File $logFile -Append
    "[$timestamp] DryRun: Would run 'git push origin $tagName'" | Out-File $logFile -Append
} else {
    try {
        git tag $tagName
        git push origin $tagName
        "[$timestamp] Created and pushed Git tag: $tagName" | Out-File $logFile -Append
    } catch {
        "[$timestamp] Failed to tag or push: $_" | Out-File $logFile -Append
        throw
    }
}

# Prepare changelog entry
$changelogEntry = @"
## [$version] - $timestamp
- Automated release tag created by CI pipeline.
"@

# Append to CHANGELOG.md
if ($DryRun) {
    "[$timestamp] DryRun: Would append changelog entry for $version" | Out-File $logFile -Append
} else {
    try {
        Add-Content -Path CHANGELOG.md -Value $changelogEntry
        "[$timestamp] Appended changelog entry for $version" | Out-File $logFile -Append
    } catch {
        "[$timestamp] Failed to update CHANGELOG.md: $_" | Out-File $logFile -Append
        throw
    }
}

"[$timestamp] Tag-Version.ps1 completed." | Out-File $logFile -Append
