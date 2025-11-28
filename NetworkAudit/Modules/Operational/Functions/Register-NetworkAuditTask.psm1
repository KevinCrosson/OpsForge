# ============================================
# Register-NetworkAuditTask.psm1
# ============================================
# Purpose:
#   - Register a daily scheduled task to run Run-NetworkAudit.ps1
#   - Uses SYSTEM account with highest privileges
#   - Can be reused in deployment scripts or CLI wrappers
# ============================================

function Register-NetworkAuditTask {
    param (
        [string]$TaskName = "NetworkAudit",                         # Task name in Task Scheduler
        [string]$ScriptPath = "C:\.PS\NetworkAudit\Run-NetworkAudit.ps1",  # Path to audit script
        [string]$StartTime = "08:00"                                # Daily start time (HH:mm)
    )

    # --- Validate script path ---
    if (-not (Test-Path $ScriptPath)) {
        Write-Error "Audit script not found: $ScriptPath"
        return
    }

    # --- Define task action ---
    $action = New-ScheduledTaskAction -Execute "powershell.exe" `
        -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptPath`""

    # --- Define daily trigger ---
    $trigger = New-ScheduledTaskTrigger -Daily -At $StartTime

    # --- Define task settings ---
    $settings = New-ScheduledTaskSettingsSet `
        -AllowStartIfOnBatteries `
        -DontStopIfGoingOnBatteries `
        -StartWhenAvailable `
        -WakeToRun `
        -MultipleInstances IgnoreNew

    # --- Register the task ---
    try {
        Register-ScheduledTask -TaskName $TaskName `
            -Action $action `
            -Trigger $trigger `
            -Settings $settings `
            -RunLevel Highest `
            -User "SYSTEM"

        Write-Host "Scheduled task '$TaskName' registered successfully to run at $StartTime"
    } catch {
        Write-Error "Failed to register scheduled task: $_"
    }
}