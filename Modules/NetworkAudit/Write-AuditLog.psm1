function Write-AuditLog {
    [CmdletBinding()]
    param (
        [string]$Action,
        [string]$Target,
        [string]$Details
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp | $Action | $Target | $Details"

    $logPath = "$PSScriptRoot\..\Logs\NetworkAudit.log"
    $logEntry | Add-Content -Path $logPath -Encoding UTF8
}