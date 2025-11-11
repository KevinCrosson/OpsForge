# ============================================
# Purge-OldLogs.ps1
# ============================================
# Purpose:
#   - Delete log files older than a specified retention period
#   - Log actions and errors to a cleanup log
# ============================================

# --- Configuration ---
$logFolder = "C:\.PS\Logs\NetworkAudit"     # Folder containing logs to purge
$retentionDays = 30                         # Number of days to keep logs
$cleanupLogPath = "$logFolder\PurgeLog.txt" # Log file for cleanup actions

# --- Logging helper function ---
function Log-Cleanup {
    param ([string]$msg)
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    Add-Content -Path $cleanupLogPath -Value "$timestamp - $msg"
}

# --- Validate log folder existence ---
if (-not (Test-Path $logFolder)) {
    Log-Cleanup "Log folder not found: $logFolder"
    Write-Error "Log folder does not exist: $logFolder"
    exit 1
}

# --- Calculate cutoff date ---
$cutoffDate = (Get-Date).AddDays(-$retentionDays)
Log-Cleanup "Starting purge. Retention