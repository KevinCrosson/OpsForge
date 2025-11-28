<#
.SYNOPSIS
    Dispatcher wrapper for Capture-Packets.ps1 with dry-run and logging support.

.DESCRIPTION
    Invokes Capture-Packets.ps1 to record network traffic and logs execution metadata to Logs/ci/.
    Supports dry-run simulation and scheduled execution.

.PARAMETER Duration
    Optional duration in seconds. Default is 30.

.PARAMETER DryRun
    Simulates execution without capturing packets.

.PARAMETER Verbose
    Enables detailed output.

.EXAMPLE
    .\Dispatch-CapturePackets.ps1 -Duration 60 -Verbose
#>

[CmdletBinding()]
param (
    [int]$Duration = 30,
    [switch]$DryRun,
    [switch]$Verbose
)

# --- Paths ---
$Root = Resolve-Path "$PSScriptRoot\..\.."
$LogDir = Join-Path $Root "Logs\ci"
$LogFile = Join-Path $LogDir "DispatcherLog_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
$CaptureScript = Join-Path $Root "Scripts\Network\Capture-Packets.ps1"

# --- Ensure Log Directory Exists ---
if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}

# --- Logger ---
function Write-Log {
    param ([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "$timestamp | $Message"
    Add-Content -Path $LogFile -Value $entry
    Write-Host $entry
}

# --- Execution ---
Write-Log "▶ Starting packet capture dispatcher..."

if ($DryRun) {
    Write-Log "DryRun: Would invoke $CaptureScript with -Duration $Duration"
} elseif (Test-Path $CaptureScript) {
    try {
        & $CaptureScript -Duration $Duration -Verbose:$Verbose
        Write-Log "✅ Completed: $CaptureScript"
    } catch {
        Write-Log "❌ Error in {$CaptureScript}: $_"
    }
} else {
    Write-Log "⚠️ Missing: $CaptureScript"
}

Write-Log "🧾 Dispatcher log saved to: $LogFile"