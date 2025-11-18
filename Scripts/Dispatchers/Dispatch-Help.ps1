<#
.SYNOPSIS
    Lists available DevTasks and provides usage examples for dispatchers.

.DESCRIPTION
    Dynamically discovers supported tasks from DevTasks and Release folders.
    Shows usage examples for Dispatch-DevTasks.ps1, Dispatch-All.ps1, and Dispatch-QuickCheck.ps1.

.AUTHOR
    Kevin Crosson

.TAGS
    Help, Dispatcher, DevTasks, Onboarding, CI
#>

# Resolve repo root
$RepoRoot = git rev-parse --show-toplevel

# Define script folders
$DevTasksPath = Join-Path $RepoRoot "Modules\DevTasks\Scripts"
$ReleasePath  = Join-Path $RepoRoot "DevRunner\Scripts\Release"

# Discover available task scripts
$taskScripts = @()
$taskScripts += Get-ChildItem -Path $DevTasksPath -Filter *.ps1 -ErrorAction SilentlyContinue
$taskScripts += Get-ChildItem -Path $ReleasePath -Filter *.ps1 -ErrorAction SilentlyContinue

# Extract task names
$taskNames = $taskScripts | ForEach-Object {
    $_.BaseName -replace '^(Lint|Validate|Export|Tag|Bundle|Generate)-', ''
} | Sort-Object -Unique

# Display header
Write-Host "`n Available DevTasks:" -ForegroundColor Cyan
foreach ($name in $taskNames) {
    Write-Host " - $name"
}

# Usage examples
Write-Host "`n Usage Examples:" -ForegroundColor Yellow

Write-Host "`nRun a specific task:" -ForegroundColor Gray
Write-Host "  .\Dispatch-DevTasks.ps1 -Task metadata -DryRun -Verbose" -ForegroundColor White

Write-Host "`nRun all tasks:" -ForegroundColor Gray
Write-Host "  .\Dispatch-All.ps1 -Verbose" -ForegroundColor White

Write-Host "`nRun quick hygiene check:" -ForegroundColor Gray
Write-Host "  .\Dispatch-QuickCheck.ps1" -ForegroundColor White

Write-Host "`nView this help:" -ForegroundColor Gray
Write-Host "  .\Dispatch-Help.ps1" -ForegroundColor White

Write-Host "`n All output is logged to Logs/Dispatch/" -ForegroundColor Green
