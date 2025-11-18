<#
.SYNOPSIS
    Runs release automation tasks: metadata export, bundling, tagging, and release notes.

.DESCRIPTION
    Executes scripts in DevRunner\Scripts\Release with verbose output.
    Logs all activity to Logs/Dispatch/Dispatch-Release.log.

.AUTHOR
    Kevin Crosson

.TAGS
    Release, Metadata, Tagging, Bundling, CI
#>

# Resolve repo root using Git
$RepoRoot = git rev-parse --show-toplevel

# Define paths
$ReleasePath = Join-Path $RepoRoot "DevRunner\Scripts\Release"
$VersionFile = Join-Path $RepoRoot "VERSION.txt"
$LogFolder   = Join-Path $RepoRoot "Logs\Dispatch"
$LogFile     = Join-Path $LogFolder "Dispatch-Release.log"

# Ensure log folder exists
if (-not (Test-Path $LogFolder)) {
    New-Item -ItemType Directory -Path $LogFolder -Force | Out-Null
}

# Logging helper
function Write-Log {
    param ([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFile -Value "$timestamp [Release] $Message"
    Write-Host $Message
}

Write-Log "Starting release workflow..."

# Define release scripts in execution order
$scripts = @(
    "Export-MetadataFiles.ps1",
    "Bundle-ReleaseArtifacts.ps1",
    "Tag-Version.ps1",
    "Generate-ReleaseNotes.ps1"
)

foreach ($script in $scripts) {
    $path = Join-Path $ReleasePath $script

    if (Test-Path $path) {
        if ($script -eq "Tag-Version.ps1" -and (Test-Path $VersionFile)) {
            $version = Get-Content $VersionFile
            & $path -Version $version
            Write-Log "$script executed with version $version."
        } else {
            & $path
            Write-Log "$script executed."
        }
    } else {
        Write-Log "$script not found."
    }
}

Write-Log "Release workflow complete."
