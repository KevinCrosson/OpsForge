<#
.SYNOPSIS
    Dispatcher for exporting and visualizing active TCP connections.

.DESCRIPTION
    Runs Export-ClassifiedConnections.ps1 to generate JSON output for dashboard/API use.
    Can be scheduled via Task Scheduler or CI pipeline.

.EXAMPLE
    .\Dispatch-Connections.ps1 -Verbose
#>

[CmdletBinding()]
param (
    [switch]$Verbose
)

$ScriptPath = Join-Path $PSScriptRoot "..\Network\Export-ClassifiedConnections.ps1"

if (-not (Test-Path $ScriptPath)) {
    Write-Error "Export-ClassifiedConnections.ps1 not found at $ScriptPath"
    return
}

Write-Host "Running connection export..." -ForegroundColor Cyan
& $ScriptPath -Verbose:$Verbose
Write-Host "Export complete." -ForegroundColor Green