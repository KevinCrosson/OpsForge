<#
.SYNOPSIS
    Summarizes last run timestamps for all dispatchers.

.DESCRIPTION
    Scans log files in Logs/Dispatch and extracts the most recent timestamp for each dispatcher.
    Useful for CI dashboards, manual audits, and release readiness checks.

.AUTHOR
    Kevin Crosson
#>

$RepoRoot = git rev-parse --show-toplevel
$LogFolder = Join-Path $RepoRoot "Logs\Dispatch"

# Get all dispatcher logs
$logs = Get-ChildItem -Path $LogFolder -Filter *.log -ErrorAction SilentlyContinue

Write-Host "`n Dispatcher Status Summary:" -ForegroundColor Cyan

foreach ($log in $logs) {
    $lastLine = Get-Content $log.FullName | Select-Object -Last 1
    $name = $log.BaseName
    if ($lastLine -match '^\d{4}-\d{2}-\d{2}') {
        Write-Host " - {$name} $lastLine"
    } else {
        Write-Host " - {$name} No timestamp found"
    }
}
