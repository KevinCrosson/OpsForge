<#
.SYNOPSIS
    Classifies active TCP connections by trust level and logs the results.

.DESCRIPTION
    This script retrieves all active TCP connections, resolves remote IPs to hostnames,
    and classifies each connection as Local, Known, or Suspicious based on configurable rules.
    Results are logged to a timestamped file in Logs/connections/.

.PARAMETER OutputPath
    Optional path to save the classification log. Defaults to Logs/connections/ with timestamp.

.PARAMETER Verbose
    Enables detailed output to the console.

.EXAMPLE
    .\Classify-Connections.ps1 -Verbose

.NOTES
    Author: Kevin Crosson
    Project: NetworkAudit
    Module: Scripts/Network
#>

[CmdletBinding()]
param (
    [string]$OutputPath = "$(Join-Path $PSScriptRoot "..\..\Logs\connections\ConnectionReport_$(Get-Date -Format 'yyyyMMdd_HHmmss').log")",
    [switch]$Verbose
)

# --- Configuration ---
$KnownHosts = @(
    "microsoft.com",
    "github.com",
    "windowsupdate.com"
)

$LocalRanges = @(
    "127.0.0.1",
    "192.168.",
    "10.",
    "172.16.", "172.17.", "172.18.", "172.19.",
    "172.20.", "172.21.", "172.22.", "172.23.",
    "172.24.", "172.25.", "172.26.", "172.27.",
    "172.28.", "172.29.", "172.30.", "172.31."
)

# --- Helper: Classify IP ---
function Get-TrustLevel {
    param ([string]$RemoteAddress, [string]$ResolvedHost)

    if ($LocalRanges | Where-Object { $RemoteAddress.StartsWith($_) }) {
        return "Local"
    }
    elseif ($KnownHosts | Where-Object { $ResolvedHost -like "*$_*" }) {
        return "Known"
    }
    else {
        return "Suspicious"
    }
}

# --- Main Execution ---
Write-Verbose "Retrieving active TCP connections..."
$Connections = Get-NetTCPConnection | Where-Object { $_.State -eq 'Established' }

if (-not $Connections) {
    Write-Host "No active TCP connections found." -ForegroundColor Yellow
    return
}

$Results = @()

foreach ($Conn in $Connections) {
    $RemoteIP = $Conn.RemoteAddress
    $LocalPort = $Conn.LocalPort
    $RemotePort = $Conn.RemotePort

    # Attempt to resolve hostname
    try {
        $ResolvedHost = [System.Net.Dns]::GetHostEntry($RemoteIP).HostName
    } catch {
        $ResolvedHost = "Unresolved"
    }

    $Trust = Get-TrustLevel -RemoteAddress $RemoteIP -ResolvedHost $ResolvedHost

    $Entry = [PSCustomObject]@{
        Timestamp     = (Get-Date).ToString("s")
        LocalPort     = $LocalPort
        RemoteIP      = $RemoteIP
        RemotePort    = $RemotePort
        Hostname      = $ResolvedHost
        TrustLevel    = $Trust
    }

    $Results += $Entry

    if ($Verbose) {
        Write-Host "$($Entry.Timestamp) | ($RemoteIP}:{$RemotePort} ($ResolvedHost) => [$Trust]" -ForegroundColor Cyan
    }
}

# --- Output ---
$LogDir = Split-Path -Path $OutputPath -Parent
if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}

$Results | Format-Table | Out-File -FilePath $OutputPath -Encoding UTF8
Write-Host "Connection classification saved to: $OutputPath" -ForegroundColor Green