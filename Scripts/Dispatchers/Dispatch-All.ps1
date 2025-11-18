<#
.SYNOPSIS
    Runs all supported DevTasks in sequence using Dispatch-DevTasks.ps1.

.DESCRIPTION
    This script orchestrates the execution of all supported DevTasks by invoking Dispatch-DevTasks.ps1
    for each task name. It supports dry-run and verbose flags for safe testing and traceable output.

.PARAMETER DryRun
    If specified, passes -DryRun to each task dispatcher to simulate execution without making changes.

.PARAMETER Verbose
    Enables detailed output and logging for each dispatched task.

.AUTHOR
    Kevin Crosson

.TAGS
    Dispatcher, DevTasks, CI, Batch, Orchestration
#>

param (
    [switch]$DryRun,
    [switch]$Verbose
)

# Resolve the root of the Git repository
$RepoRoot = git rev-parse --show-toplevel

# Path to the main dispatcher script
$Dispatcher = Join-Path $RepoRoot "Scripts\Dispatchers\Dispatch-DevTasks.ps1"

# Define the list of supported tasks (must match -Task values accepted by Dispatch-DevTasks.ps1)
$Tasks = @(
    "validate",   # Validates folder structure and naming conventions
    "lint",       # Lints Markdown documentation
    "metadata"    # Runs metadata export, version tagging, changelog update, release bundling
)

Write-Host "`n Running all DevTasks..." -ForegroundColor Cyan

foreach ($Task in $Tasks) {
    Write-Host "`n Dispatching task: $Task" -ForegroundColor Yellow

    # Build argument list dynamically
    $taskArgs = @("-Task", $Task)
    if ($DryRun)   { $taskArgs += "-DryRun" }
    if ($Verbose)  { $taskArgs += "-Verbose" }

    # Execute the dispatcher with arguments
    & $Dispatcher @args

    # Optional: check for errors and halt if needed
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Task '$Task' failed. Halting execution." -ForegroundColor Red
        break
    }
}

Write-Host "All tasks completed." -ForegroundColor Green
