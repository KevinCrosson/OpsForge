# ============================================
# Register-NetworkAuditTask.ps1
# ============================================
# Purpose:
#   - Register a daily scheduled task to run Run-NetworkAudit.ps1
#   - Uses SYSTEM account with highest privileges
# ============================================

# --- Configuration ---
$taskName   = "NetworkAudit"
$scriptPath = "C:\.PS\NetworkAudit\Run-NetworkAudit.ps1"
$startTime  = "08:00"  # Format: HH:mm (24-hour)

# --- Validate script path ---
if (-not (Test-Path $scriptPath)) {
    Write-Error "Audit script not found: $scriptPath"
    exit 1
}

# --- Define task action ---
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""

# --- Define daily trigger ---
$trigger = New-ScheduledTaskTrigger -Daily -At $startTime

# --- Define task settings ---
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
    -StartWhenAvailable -WakeToRun -MultipleInstances IgnoreNew

# --- Register the task ---
try {
    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger `
        -Settings $settings -RunLevel Highest -User "SYSTEM"

    Write-Host "Scheduled task '$taskName' registered successfully to run at $startTime"
} catch {
    Write-Error "Failed to register scheduled task: $_"
}
