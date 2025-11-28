<#
.SYNOPSIS
    Resolves IPv4 and IPv6 addresses found in scripts or logs to hostnames and exports results.

.DESCRIPTION
    This script recursively scans .ps1 and .log files under a given root directory, extracts IP addresses,
    resolves them to hostnames using DNS, performs reverse validation, and exports results to CSV and JSON.
    It supports dry-run mode, verbose output, and is dispatcher-ready for DevRunner integration.

.PARAMETER Root
    Root directory to scan for files.

.PARAMETER OutputPath
    Optional path to write the CSV log. Defaults to Logs/ResolvedHostnames-<timestamp>.csv under Root.

.PARAMETER DryRun
    Simulates resolution without performing DNS lookups or writing output.

.PARAMETER Verbose
    Enables detailed output for CI logging and audit trails.

.EXAMPLE
    .\Resolve-Hostnames.ps1 -Root "C:\.PS\NetworkAudit" -Verbose

.NOTES
    Dispatcher: Scripts/Dispatchers/Diagnostics/Resolve-Hostnames.ps1
    Output: Logs/ResolvedHostnames-YYYYMMDD-HHmmss.csv and .json
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$Root,

    [string]$OutputPath,

    [switch]$DryRun,
    [switch]$Verbose
)

# Define default output path if not provided
if (-not $OutputPath) {
    $Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $LogDir = Join-Path $Root "Logs"
    if (-not (Test-Path $LogDir)) {
        if (-not $DryRun) {
            New-Item -Path $LogDir -ItemType Directory -Force | Out-Null
        } elseif ($Verbose) {
            Write-Host "[DryRun] Would create log directory: $LogDir" -ForegroundColor Yellow
        }
    }
    $OutputPath = Join-Path $LogDir "ResolvedHostnames-$Timestamp.csv"
}

# Regex patterns for IPv4 and IPv6
$IPv4Pattern = '\b(?:\d{1,3}\.){3}\d{1,3}\b'
$IPv6Pattern = '\b(?:[A-Fa-f0-9]{1,4}:){1,7}[A-Fa-f0-9]{1,4}\b'

# Collect all .ps1 and .log files recursively
$TargetFiles = Get-ChildItem -Path $Root -Recurse -Include *.ps1, *.log -File -ErrorAction SilentlyContinue

if ($Verbose) {
    Write-Host "Scanning $($TargetFiles.Count) files for IP addresses..." -ForegroundColor Cyan
}

# Hashtable to track unique IPs and their resolution metadata
$Resolved = @{}

foreach ($File in $TargetFiles) {
    try {
        $Content = Get-Content -Path $File.FullName -Raw -ErrorAction Stop
    } catch {
        if ($Verbose) {
            Write-Warning "Failed to read file: $($File.FullName)"
        }
        continue
    }

    # Extract IPs using combined regex
    $IpMatches = [regex]::Matches($Content, "$IPv4Pattern|$IPv6Pattern")

    foreach ($Match in $IpMatches) {
        $Ip = $Match.Value
        if ($Resolved.ContainsKey($Ip)) { continue }

        $SourceFile = $File.FullName

        if ($DryRun) {
            $Resolved[$Ip] = [PSCustomObject]@{
                IP        = $Ip
                Hostname  = "[DryRun] Would resolve"
                Source    = $SourceFile
                Status    = "DryRun"
            }
            continue
        }

        try {
            # Forward resolution
            $Entry    = [System.Net.Dns]::GetHostEntry($Ip)
            $Hostname = $Entry.HostName

            # Reverse validation
            $ReverseIPs = [System.Net.Dns]::GetHostAddresses($Hostname) | ForEach-Object { $_.ToString() }
            $IsValid    = $ReverseIPs -contains $Ip
            $Note       = if ($IsValid) { "Validated" } else { "Mismatch" }
        } catch {
            $Hostname = "Unresolved"
            $Note     = "Error"
        }

        $Resolved[$Ip] = [PSCustomObject]@{
            IP        = $Ip
            Hostname  = $Hostname
            Source    = $SourceFile
            Status    = $Note
        }

        if ($Verbose) {
            Write-Host "$Ip -> $Hostname [$Note]" -ForegroundColor Gray
        }
    }
}

# Export to CSV
if (-not $DryRun) {
    try {
        $Resolved.Values | Sort-Object IP | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8
        Write-Host "Resolution CSV saved to $OutputPath" -ForegroundColor Green
    } catch {
        Write-Warning "Failed to write CSV to $OutputPath"
    }

    # Export to JSON for dashboard integration
    $JsonPath = [System.IO.Path]::ChangeExtension($OutputPath, "json")
    try {
        $Resolved.Values | Sort-Object IP | ConvertTo-Json -Depth 3 | Set-Content -Path $JsonPath -Encoding UTF8
        Write-Host "JSON export saved to $JsonPath" -ForegroundColor DarkCyan
    } catch {
        Write-Warning "Failed to write JSON to $JsonPath"
    }
} else {
    Write-Host "[DryRun] CSV and JSON not written." -ForegroundColor Yellow
}

Write-Host "Hostname resolution complete." -ForegroundColor Green
