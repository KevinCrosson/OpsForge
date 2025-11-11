# ============================================
# Run-NetworkAudit.ps1
# ============================================
# Purpose:
#   - Load secure environment variables
#   - Scan active TCP connections
#   - Log results and flag untrusted IPs
#   - Send alert email if needed
# ============================================

# --- Resolve module paths ---
$moduleRoot  = "$PSScriptRoot\modules\NetworkAudit"
$authRoot    = "$PSScriptRoot\modules\Auth"
$commonRoot  = "$PSScriptRoot\modules\Common"
$loggingRoot = "$PSScriptRoot\modules\Logging"

# --- Import core NetworkAudit modules ---
Import-Module "$moduleRoot\Load-EnvSecure.psm1"
Import-Module "$moduleRoot\Scan-NetworkConnections.psm1"
Import-Module "$moduleRoot\Send-AlertEmail.psm1"

# --- Import shared utility modules ---
Import-Module "$authRoot\Load-Credentials.psm1"
Import-Module "$commonRoot\Convert-Timestamp.psm1"
Import-Module "$loggingRoot\Write-LogEntry.psm1"

# --- Load environment variables securely ---
$envVars = Load-EnvSecure -VerboseLog

# --- Define log path ---
$logPath = "$PSScriptRoot\AuditLog.txt"

# --- Run network scan ---
$results = Scan-NetworkConnections -VerboseLog

# --- Log each connection ---
foreach ($entry in $results) {
    $status = if ($entry.IsTrusted) { "Trusted" } else { "Unverified" }
    $timestamp = Convert-Timestamp -DateTime (Get-Date)
    $msg = "$timestamp | $status | $($entry.RemoteIP):$($entry.RemotePort) → $($entry.Hostname)"
    Write-LogEntry -Message $msg -LogPath $logPath
}

# --- Filter untrusted connections ---
$untrusted = $results | Where-Object { -not $_.IsTrusted }

# --- Send alert if untrusted connections found ---
if ($untrusted.Count -gt 0) {
    $body = "Unverified connections detected:`n`n"
    foreach ($entry in $untrusted) {
        $body += "$($entry.RemoteIP):$($entry.RemotePort) → $($entry.Hostname)`n"
    }

    Send-AlertEmail -From $envVars["EMAIL_FROM"] -To $envVars["EMAIL_TO"] `
        -Subject "NetworkAudit Alert: Unverified Connections" -Body $body `
        -SmtpServer $envVars["SMTP_SERVER"] -Port $envVars["SMTP_PORT"] `
        -Username $envVars["EMAIL_USERNAME"] -Password $envVars["EMAIL_PASSWORD"]
}