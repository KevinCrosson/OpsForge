<#
.SYNOPSIS
    Runs fast pre-commit hygiene checks: folder validation and Markdown linting.

.DESCRIPTION
    Executes Validate-FolderStructure.ps1 and Lint-Markdown.ps1 with verbose output.
    Logs all activity to Logs/Dispatch/Dispatch-QuickCheck.log.

.AUTHOR
    Kevin Crosson

.TAGS
    QuickCheck, PreCommit, Validation, Linting, CI
#>

# Resolve repo root using Git
$RepoRoot = git rev-parse --show-toplevel

# Define paths
$ValidateScript = Join-Path $RepoRoot "Modules\DevTasks\Scripts\Validate-FolderStructure.ps1"
$LintScript     = Join-Path $RepoRoot "Modules\DevTasks\Scripts\Lint-Markdown.ps1"
$LogFolder      = Join-Path $RepoRoot "Logs\Dispatch"
$LogFile        = Join-Path $LogFolder "Dispatch-QuickCheck.log"

# Ensure log folder exists
if (-not (Test-Path $LogFolder)) {
    New-Item -ItemType Directory -Path $LogFolder -Force | Out-Null
}

# Logging helper
function Write-Log {
    param ([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFile -Value "$timestamp [QuickCheck] $Message"
    Write-Host $Message
}

Write-Log "Starting quick hygiene check..."

# Run folder validation
if (Test-Path $ValidateScript) {
    & $ValidateScript -Strict
    Write-Log "Folder structure validated."
} else {
    Write-Log "Validate-FolderStructure.ps1 not found."
}

# Run Markdown linting
if (Test-Path $LintScript) {
    & $LintScript
    Write-Log "Markdown linting complete."
} else {
    Write-Log "Lint-Markdown.ps1 not found."
}

Write-Log "QuickCheck complete."
