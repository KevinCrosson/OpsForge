<#
.SYNOPSIS
    Parses dispatcher logs and summarizes module execution history.

.DESCRIPTION
    Scans all DispatcherLog_*.log files in Logs/ci/, extracts timestamps, module labels, and statuses,
    and outputs a summary JSON file for dashboard visualization.

.PARAMETER OutputPath
    Optional path to save the summary JSON. Defaults to Data/exports/DispatcherSummary.json.

.EXAMPLE
    .\Summarize-DispatcherLogs.ps1 -Verbose
#>

[CmdletBinding()]
param (
    [string]$OutputPath = "$(Join-Path $PSScriptRoot '..\..\Data\exports\DispatcherSummary.json')",
    [switch]$Verbose
)

$LogDir = Join-Path $PSScriptRoot '..\..\Logs\ci'
$Summary = @()

# Parse each log file
Get-ChildItem -Path $LogDir -Filter "DispatcherLog_*.log" | ForEach-Object {
    $LogFile = $_.FullName
    $Session = @()

    Get-Content $LogFile | ForEach-Object {
        if ($_ -match '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} \| (.+)$') {
            $line = $Matches[1]
            $timestamp = $_.Substring(0, 19)
            $status = if ($line -match '✅ Completed') { "Success" }
                      elseif ($line -match '❌ Error') { "Error" }
                      elseif ($line -match '⚠️ Missing') { "Missing" }
                      elseif ($line -match 'DryRun') { "DryRun" }
                      else { "Info" }

            $Session += [PSCustomObject]@{
                Timestamp = $timestamp
                Message   = $line
                Status    = $status
                LogFile   = $_.PSParentPath
            }
        }
    }

    $Summary += $Session
}

# Export to JSON
$ExportDir = Split-Path $OutputPath -Parent
if (-not (Test-Path $ExportDir)) {
    New-Item -ItemType Directory -Path $ExportDir -Force | Out-Null
}

$Summary | ConvertTo-Json -Depth 3 | Set-Content -Path $OutputPath -Encoding UTF8
Write-Host "Dispatcher summary exported to: $OutputPath" -ForegroundColor Green