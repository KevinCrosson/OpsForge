<#
.SYNOPSIS
    Logs active TCP connections with hostname resolution, trust-level classification, reverse DNS validation, and process inspection.

.DESCRIPTION
    Captures all established TCP connections using Get-NetTCPConnection.
    Enriches each entry with:
      - Timestamp
      - Remote IP and Port
      - Hostname (via DNS)
      - TrustLevel (Local, Known, Suspicious, Unknown)
      - ReverseDNSMatch (true/false)
      - Owning process info (PID and process name)
    Exports results to both JSON and CSV in Data/exports/.

.PARAMETER OutputStem
    Optional base filename stem. Defaults to Connections_YYYYMMDD_HHMMSS.

.PARAMETER Verbose
    Enables detailed output.

.EXAMPLE
    .\Log-ActiveConnections.ps1 -Verbose
#>

[CmdletBinding()]
param (
    [string]$OutputStem = "Connections_$(Get-Date -Format 'yyyyMMdd_HHmmss')",
    [switch]$Verbose
)

# --- Setup paths ---
$ExportDir = Join-Path $PSScriptRoot '..\..\Data\exports'
$JsonPath  = Join-Path $ExportDir "$OutputStem.json"
$CsvPath   = Join-Path $ExportDir "$OutputStem.csv"

# --- Ensure export directory exists ---
if (-not (Test-Path $ExportDir)) {
    New-Item -ItemType Directory -Path $ExportDir -Force | Out-Null
    Write-Verbose "Created export directory: $ExportDir"
}

# --- Helper: Classify trust level based on IP ---
function Get-TrustLevel {
    param ([string]$RemoteIP)
    switch -Wildcard ($RemoteIP) {
        "127.*"     { return "Local" }
        "::1"       { return "Local" }
        "192.168.*" { return "Known" }
        "10.*"      { return "Known" }
        "172.16.*"  { return "Known" }
        "0.0.0.0"   { return "Unknown" }
        "::"        { return "Unknown" }
        default     { return "Suspicious" }
    }
}

# --- Capture TCP connections ---
Write-Host "🔍 Capturing active TCP connections..." -ForegroundColor Cyan
$connections = Get-NetTCPConnection | Where-Object { $_.State -eq 'Established' }

# --- Enrich each connection ---
$results = @()
foreach ($conn in $connections) {
    $remoteIP   = $conn.RemoteAddress
    $remotePort = $conn.RemotePort
    $localPID   = $conn.OwningProcess
    $trust      = Get-TrustLevel -RemoteIP $remoteIP

    # Resolve hostname
    try {
        $hostname = [System.Net.Dns]::GetHostEntry($remoteIP).HostName
    } catch {
        $hostname = "Unresolved"
    }

    # Reverse DNS validation
    $reverseMatch = $false
    try {
        $resolvedIPs = [System.Net.Dns]::GetHostAddresses($hostname) | ForEach-Object { $_.ToString() }
        if ($resolvedIPs -contains $remoteIP) {
            $reverseMatch = $true
        }
    } catch {
        $reverseMatch = $false
    }

    # Get owning process name
    try {
        $procName = (Get-Process -Id $localPID -ErrorAction SilentlyContinue).ProcessName
    } catch {
        $procName = "Unknown"
    }

    # Build connection object
    $results += [PSCustomObject]@{
        Timestamp        = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        RemoteIP         = $remoteIP
        RemotePort       = $remotePort
        Hostname         = $hostname
        TrustLevel       = $trust
        ReverseDNSMatch  = $reverseMatch
        PID              = $localPID
        ProcessName      = $procName
    }
}

# --- Export to JSON ---
$results | ConvertTo-Json -Depth 3 | Set-Content -Path $JsonPath -Encoding UTF8
Write-Host "✅ JSON export saved to: $JsonPath" -ForegroundColor Green

# --- Export to CSV ---
$results | Export-Csv -Path $CsvPath -NoTypeInformation -Encoding UTF8
Write-Host "✅ CSV export saved to: $CsvPath" -ForegroundColor Green