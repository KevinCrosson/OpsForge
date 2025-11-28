<#
.SYNOPSIS
    Captures live network packets and saves them to a .pcapng file.

.DESCRIPTION
    This script uses the built-in Windows packet capture tool (pktmon) to record network traffic.
    It converts the output to .pcapng format for analysis in Wireshark or other forensic tools.
    The capture is timestamped and saved to Logs/packets/.

.PARAMETER Duration
    Optional duration in seconds to run the capture. Default is 30 seconds.

.PARAMETER OutputPath
    Optional override for the output file path. Defaults to Logs/packets/Capture_YYYYMMDD_HHMMSS.pcapng.

.PARAMETER Verbose
    Enables detailed console output.

.EXAMPLE
    .\Capture-Packets.ps1 -Duration 60 -Verbose

.NOTES
    Author: Kevin Crosson
    Project: NetworkAudit
    Location: Scripts/Network
#>

[CmdletBinding()]
param (
    [int]$Duration = 30,
    [string]$OutputPath = "$(Join-Path $PSScriptRoot '..\..\Logs\packets\Capture_$(Get-Date -Format 'yyyyMMdd_HHmmss').pcapng')",
    [switch]$Verbose
)

# --- Setup Paths ---
$LogDir = Split-Path $OutputPath -Parent
$TmpEtl = Join-Path $LogDir "temp.etl"

# --- Ensure Log Directory Exists ---
if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
    Write-Verbose "Created log directory: $LogDir"
}

# --- Start Packet Capture ---
Write-Host "🟢 Starting packet capture for $Duration seconds..." -ForegroundColor Cyan
Start-Process -FilePath "pktmon.exe" -ArgumentList "start --etw -p 0" -NoNewWindow
Start-Sleep -Seconds $Duration

# --- Stop Capture ---
Write-Host "🛑 Stopping capture..." -ForegroundColor Cyan
Start-Process -FilePath "pktmon.exe" -ArgumentList "stop" -NoNewWindow
Start-Sleep -Seconds 2

# --- Convert ETL to PCAPNG ---
Write-Host "🔄 Converting capture to .pcapng format..." -ForegroundColor Cyan
Start-Process -FilePath "pktmon.exe" -ArgumentList "convert -o `"$OutputPath`"" -NoNewWindow
Start-Sleep -Seconds 2

# --- Cleanup ---
Remove-Item $TmpEtl -ErrorAction SilentlyContinue

# --- Completion ---
Write-Host "✅ Packet capture saved to: $OutputPath" -ForegroundColor Green