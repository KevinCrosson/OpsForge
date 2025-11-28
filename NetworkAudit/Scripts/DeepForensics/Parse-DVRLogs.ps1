<#
.SYNOPSIS
    Unified parser for DVR/NVR logs:
    - HDD S.M.A.R.T. health anomalies
    - Video tampering alarms
    - System recording status
    - SHA-256 hash for chain-of-custody

.DESCRIPTION
    This script ingests raw DVR/NVR logs and produces structured JSON + hash artifacts.
    It folds in tamper-event parsing logic (previously Parse-DVRTamperEvents.ps1) so
    everything is handled in one master parser.

.PARAMETER LogPath
    Path to the DVR/NVR log file.

.EXAMPLE
    .\Parse-DVRLogs.ps1 -LogPath "C:\Logs\dvr_events.txt"

.NOTES
    Author: Kevin Crosson (DeepForensics module)
    Version: 2.0
    License: Commercial-ready, audit-friendly
#>

param (
    [Parameter(Mandatory=$true)]
    [string]$LogPath
)

# -------------------------------
# Initialize structured containers
# -------------------------------
$Results = @{
    HDDHealth    = @()
    TamperEvents = @()
    SystemStatus = @()
}

# -------------------------------
# Read the log file
# -------------------------------
try {
    $LogContent = Get-Content -Path $LogPath -ErrorAction Stop
} catch {
    Write-Error "Failed to read log file at $LogPath. $_"
    exit 1
}

# -------------------------------
# Parse HDD S.M.A.R.T. section
# -------------------------------
if ($LogContent -match "Minor Type: HDD S.M.A.R.T.") {
    $SmartBlock = $LogContent | Select-String "Attribute name" -Context 0,25
    foreach ($line in $SmartBlock.Context.PostContext) {
        if ($line -match "^\s*\w+") {
            $parts = $line -split "\s{2,}"
            $attr = @{
                ID     = $parts[0].Trim()
                Name   = $parts[1].Trim()
                Value  = $parts[4].Trim()
                Worst  = $parts[5].Trim()
                Raw    = $parts[6].Trim()
                Status = $parts[7].Trim()
            }
            $Results.HDDHealth += $attr
        }
    }
}

# Flag anomalies
$Anomalies = $Results.HDDHealth | Where-Object {
    ($_."Name" -eq "Reallocated Sector Count" -and [int]$_.Raw -gt 0) -or
    ($_."Name" -eq "Ultra ATA CRC Error Rate" -and [int]$_.Raw -gt 0) -or
    ($_."Name" -eq "Current Pending Sector Count" -and [int]$_.Raw -gt 0)
}

# -------------------------------
# Parse Tamper Events (folded in)
# -------------------------------
$TamperMatches = $LogContent | Select-String "Video Tampering Detection Started"
foreach ($match in $TamperMatches) {
    $timestampLine = ($LogContent[$match.LineNumber - 2])
    $timestamp = ($timestampLine -split "\s+")[1..2] -join " "

    $Results.TamperEvents += @{
        Timestamp = $timestamp
        Camera    = "A1"   # Could be parsed dynamically if multiple cameras
        Event     = "Tampering Detected"
    }
}

# -------------------------------
# Parse System Running Status
# -------------------------------
$SystemBlock = $LogContent | Select-String "System Running Status" -Context 0,25
foreach ($line in $SystemBlock.Context.PostContext) {
    if ($line -match "^\d,") {
        $fields = $line -split ","
        $Results.SystemStatus += @{
            Channel   = $fields[0]
            RecType   = $fields[2]
            Stat      = $fields[3]
            Online    = $fields[8]
            Disk      = $fields[9]
        }
    }
}

# -------------------------------
# Build final audit object
# -------------------------------
$Audit = @{
    HDDAnomalies = $Anomalies
    TamperEvents = $Results.TamperEvents
    SystemStatus = $Results.SystemStatus
}

# -------------------------------
# Export results to JSON
# -------------------------------
$OutputPath = Join-Path (Split-Path $LogPath -Parent) "DVR_Audit.json"
$Audit | ConvertTo-Json -Depth 4 | Out-File $OutputPath -Encoding UTF8

# -------------------------------
# Compute SHA-256 hash of JSON
# -------------------------------
$Hash = Get-FileHash -Path $OutputPath -Algorithm SHA256
$HashPath = Join-Path (Split-Path $LogPath -Parent) "DVR_Audit.hash"
$Hash.Hash | Out-File $HashPath -Encoding ASCII

Write-Host "Audit complete. Results saved to $OutputPath" -ForegroundColor Cyan
Write-Host "SHA-256 hash saved to $HashPath" -ForegroundColor Green
Write-Host "Hash value: $($Hash.Hash)" -ForegroundColor Yellow
