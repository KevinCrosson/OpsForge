<#
.SYNOPSIS
Logs active TCP connections and flags non-Microsoft IPs.

.DESCRIPTION
Retrieves established TCP connections, resolves remote IPs, and logs results to an external folder.
Supports dry-run and verbose modes. Designed for integration with NetworkAudit and CI pipelines.

.PARAMETER LogRoot
Root folder for external logs (e.g., C:\NetworkAuditLogs).

.PARAMETER DryRun
Simulates execution without writing logs.

.PARAMETER Verbose
Enables detailed console output.

.NOTES
Author: Kevin Crosson
Date: 2025-11-13
#>

function Get-NetworkConnections {
    param (
        [string]$LogRoot = "C:\NetworkAuditLogs",
        [switch]$DryRun,
        [switch]$Verbose
    )

    # Create timestamped subfolder for this run
    $Timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $RunLogDir = Join-Path $LogRoot $Timestamp
    if (-not (Test-Path $RunLogDir)) {
        New-Item -Path $RunLogDir -ItemType Directory | Out-Null
    }

    # Define log path
    $LogPath = Join-Path $RunLogDir "ConnectionLog.txt"

    function Write-VerboseLog {
    if ($Verbose) {
        Write-Host "[VERBOSE] $args" -ForegroundColor Cyan
    }
    }
    Log-Verbose "Retrieving active TCP connections..."
    $Connections = Get-NetTCPConnection | Where-Object { $_.State -eq "Established" }

    $Results = foreach ($conn in $Connections) {
        $RemoteIP = $conn.RemoteAddress
        $LocalIP = $conn.LocalAddress
        $RemotePort = $conn.RemotePort
        $LocalPort = $conn.LocalPort

        # Flag non-Microsoft IPs (simple heuristic)
        $IsMicrosoft = ($RemoteIP -like "*.microsoft.com" -or $RemoteIP -like "13.*" -or $RemoteIP -like "20.*")

        [PSCustomObject]@{
            Timestamp   = $Timestamp
            LocalIP     = $LocalIP
            LocalPort   = $LocalPort
            RemoteIP    = $RemoteIP
            RemotePort  = $RemotePort
            Status      = if ($IsMicrosoft) { "Microsoft" } else { "UNKNOWN" }
        }
    }

    if (-not $DryRun) {
        $Results | Format-Table | Out-String | Set-Content -Path $LogPath
        Log-Verbose "Connection log saved to $LogPath"
    } else {
        Log-Verbose "Dry-run mode: connection log not written."
    }
}