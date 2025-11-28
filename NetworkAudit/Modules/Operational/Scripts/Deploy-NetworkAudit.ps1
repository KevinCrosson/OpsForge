# ============================================
# Deploy-NetworkAudit.ps1
# ============================================
# Purpose:
#   - Import all modules
#   - Register scheduled task
#   - Purge old logs
# ============================================

# --- Import modules ---
# BROKEN: # BROKEN: Import-Module "C:\.PS\Modules\Operational\Functions\Register-NetworkAuditTask.psm1"
# BROKEN: # BROKEN: Import-Module "C:\.PS\Modules\Operational\Functions\Purge-OldLogs.psm1"

# --- Run deployment steps ---
try {
    Register-NetworkAuditTask -ScriptPath "C:\.PS\NetworkAudit\Run-NetworkAudit.ps1" -TaskName "NetworkAudit" -Time "08:00"
    Write-Host "Scheduled task registered"
} catch {
    Write-Error "Failed to register task: $_"
}

try {
    Purge-OldLogs -LogFolder "C:\.PS\Logs\NetworkAudit" -RetentionDays 30
    Write-Host "Old logs purged"
} catch {
    Write-Error "Failed to purge logs: $_"
}

