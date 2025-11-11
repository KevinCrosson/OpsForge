# ============================================
# Log-NetworkConnection.ps1
# ============================================
# Purpose:
#   - Manually log a specific network connection
#   - Useful for testing, investigation, or manual overrides
# ============================================

param (
    [Parameter(Mandatory=$true)]
    [string]$RemoteIP,

    [Parameter(Mandatory=$true)]
    [int]$RemotePort,

    [string]$Hostname = "Unknown",

    [switch]$Trusted
)

# --- Resolve module paths ---
$commonRoot  = "$PSScriptRoot\..\modules\Common"
$loggingRoot = "$PSScriptRoot\..\modules\Logging"

# --- Import required modules ---
Import-Module "$commonRoot\Convert-Timestamp.psm1"
Import-Module "$loggingRoot\Write-LogEntry.psm1"

# --- Define log path ---
$logPath = "$PSScriptRoot\..\AuditLog.txt"

# --- Format status label ---
$status = if ($Trusted.IsPresent) { "Trusted" } else { "Unverified" }

# --- Format timestamp ---
$timestamp = Convert-Timestamp -DateTime (Get-Date)

# --- Compose log message ---
$msg = "$timestamp | $status | $RemoteIP:$RemotePort → $Hostname"

# --- Write to log ---
Write-LogEntry -Message $msg -LogPath $logPath

# --- Output to console ---
Write-Host "Logged: $msg" -ForegroundColor Cyan