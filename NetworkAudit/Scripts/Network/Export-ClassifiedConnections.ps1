<#
.SYNOPSIS
    Exports classified TCP connection data to JSON for dashboard/API integration.

.DESCRIPTION
    This script invokes Classify-Connections.ps1 internally, captures its output as structured objects,
    and writes the results to a JSON file in a predictable location (e.g., Data/exports/).
    This enables the Flask dashboard to serve the data via an API route like /api/connections.

.PARAMETER OutputPath
    Optional override for the JSON export path. Defaults to Data/exports/ActiveConnections.json.

.PARAMETER Verbose
    Enables detailed console output.

.EXAMPLE
    .\Export-ClassifiedConnections.ps1 -Verbose

.NOTES
    Author: Kevin Crosson
    Project: NetworkAudit
    Module: Scripts/Network
#>

[CmdletBinding()]
param (
    [string]$OutputPath = "$(Join-Path $PSScriptRoot '..\..\Data\exports\ActiveConnections.json')",
    [switch]$Verbose
)

# --- Ensure Output Directory Exists ---
$ExportDir = Split-Path -Path $OutputPath -Parent
if (-not (Test-Path $ExportDir)) {
    New-Item -ItemType Directory -Path $ExportDir -Force | Out-Null
    Write-Verbose "Created export directory: $ExportDir"
}

# --- Invoke Classifier Logic Inline ---
function Get-TrustLevel {
    param ([string]$RemoteAddress, [string]$ResolvedHost)

    $LocalRanges = @(
        "127.0.0.1", "192.168.", "10.",
        "172.16.", "172.17.", "172.18.", "172.19.",
        "172.20.", "172.21.", "172.22.", "172.23.",
        "172.24.", "172.25.", "172.26.", "172.27.",
        "172.28.", "172.29.", "172.30.", "172.31."
    )

    $KnownHosts = @("microsoft.com", "github.com", "windowsupdate.com")

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

Write-Verbose "Retrieving active TCP connections..."
$Connections = Get-NetTCPConnection | Where-Object { $_.State -eq 'Established' }

$Results = @()

foreach ($Conn in $Connections) {
    $RemoteIP = $Conn.RemoteAddress
    $LocalPort = $Conn.LocalPort
    $RemotePort = $Conn.RemotePort

    try {
        $ResolvedHost = [System.Net.Dns]::GetHostEntry($RemoteIP).HostName
    } catch {
        $ResolvedHost = "Unresolved"
    }

    $Trust = Get-TrustLevel -RemoteAddress $RemoteIP -ResolvedHost $ResolvedHost

    $Results += [PSCustomObject]@{
        Timestamp     = (Get-Date).ToString("s")
        LocalPort     = $LocalPort
        RemoteIP      = $RemoteIP
        RemotePort    = $RemotePort
        Hostname      = $ResolvedHost
        TrustLevel    = $Trust
    }
}

# --- Export to JSON ---
$Results | ConvertTo-Json -Depth 3 | Set-Content -Path $OutputPath -Encoding UTF8
Write-Host "Exported classified connections to: $OutputPath" -ForegroundColor Green