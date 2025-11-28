# ============================================
# Purge-OldLogs.psm1
# ============================================
# Purpose:
#   - Delete log files older than a specified retention period
#   - Log actions and errors to a cleanup log
# ============================================

function remove-OldLogs {
    param (
        [string]$LogFolder = "C:\.PS\Logs\NetworkAudit",  # Folder containing logs
        [int]$RetentionDays = 30,                         # Days to keep logs
        [string]$CleanupLogPath = "$LogFolder\PurgeLog.txt"  # Log file for purge actions
    )

    # --- Ensure log folder exists ---
    if (-not (Test-Path $LogFolder)) {
        Write-Error "Log folder not found: $LogFolder"
        return
    }

    # --- Logging helper ---
    function Clear-LogFiles {
        param ([string]$msg)
        $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        Add-Content -Path $CleanupLogPath -Value "$timestamp - $msg"
    }

    # --- Calculate cutoff date ---
    $cutoffDate = (Get-Date).AddDays(-$RetentionDays)
    Log-Cleanup "Starting purge. Retention: $RetentionDays days. Cutoff: $cutoffDate"

    # --- Get old files ---
    try {
        $oldFiles = Get-ChildItem -Path $LogFolder -File | Where-Object {
            $_.LastWriteTime -lt $cutoffDate
        }

        foreach ($file in $oldFiles) {
            try {
                Remove-Item -Path $file.FullName -Force
                Log-Cleanup "Deleted: $($file.Name) (Last modified: $($file.LastWriteTime))"
            } catch {
                Log-Cleanup "Failed to delete: $($file.Name) — $_"
            }
        }

        $count = $oldFiles.Count
        Log-Cleanup "Purge complete. $count files deleted."
    } catch {
        Log-Cleanup "Error during purge: $_"
        Write-Error "Error during purge: $_"
    }
}