<#
.SYNOPSIS
  Logs active TCP connections and flags external remote IPs.

.DESCRIPTION
  This script scans established TCP connections using Get-NetTCPConnection, extracts key details,
  and logs each connection with a timestamp. External IPs are flagged for inspection.
  Uses Write-AuditLog.psm1 for structured logging. Supports dry-run mode and external log path override.

.PARAMETER LogPath
  Optional path to write the connection log. Defaults to Logs\NetworkAudit.log.

.PARAMETER DryRun
  If specified, prints log entries to console instead of writing to file.

.EXAMPLE
  .\Log-NetworkConnection.ps1 -LogPath "D:\AuditLogs\Connections.log" -DryRun
#>

param (
    [string]$LogPath = "$PSScriptRoot\..\Logs\NetworkAudit.log",
    [switch]$DryRun
)

# Import audit logger module
# BROKEN: # BROKEN: Import-Module "$PSScriptRoot\Write-AuditLog.psm1" -Force

# Retrieve all established TCP connections
$connections = Get-NetTCPConnection |
    Where-Object { $_.State -eq "Established" } |
    Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, OwningProcess, Protocol

# Initialize counters
$entryCount = 0
$externalCount = 0

foreach ($conn in $connections) {
    # Ã°Å¸â€Â Extract connection details
    $localIP     = $conn.LocalAddress
    $localPort   = $conn.LocalPort
    $remoteIP    = $conn.RemoteAddress
    $remotePort  = $conn.RemotePort
    $protocol    = $conn.Protocol
    $processId   = $conn.OwningProcess

    # Flag external IPs (exclude loopback and private ranges)
    $isExternal = (
        $remoteIP -and
        $remoteIP -notlike "127.*" -and
        $remoteIP -notlike "192.168.*" -and
        $remoteIP -notlike "10.*" -and
        $remoteIP -notlike "::1" -and
        $remoteIP -ne $localIP
    )

    # Format log entry
    $action  = "TCP Connection"
    $target  = "${localIP}:${localPort} Ã¢â€ â€™ ${remoteIP}:${remotePort}"
    $details = "Protocol=${protocol}; Process=${processId}"
    if ($isExternal) {
        $details += "; External IP detected"
        $externalCount++
    }

    # Rotate and archive if log exceeds 5MB
    $maxSizeMB = 5
    if ((Test-Path $LogPath) -and ((Get-Item $LogPath).Length -gt ($maxSizeMB * 1MB))) {
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $archivePath = "$LogPath.$timestamp.zip"

    Compress-Archive -Path $LogPath -DestinationPath $archivePath -Force
    Clear-Content -Path $LogPath
}



    # Write to audit log (or preview if dry-run)
    Write-AuditLog -Action $action -Target $target -Details $details -LogPath $LogPath -DryRun:$DryRun
    $entryCount++
}

# Summary output for CI or console
Write-Host "$entryCount connections logged to $LogPath"
if ($externalCount -gt 0) {
    Write-Host "$externalCount external IPs detected"
}

if ($externalCount -gt 0) {
    $subject = "NetworkAudit Alert: $externalCount External IPs Detected"
    $body = @"
Scan completed at $(Get-Date -Format "yyyy-MM-dd HH:mm:ss").
$externalCount external connections were flagged.

Log file: $LogPath
"@

    Send-MailMessage -To "alerts@yourdomain.com" `
                     -From "networkaudit@yourdomain.com" `
                     -Subject $subject `
                     -Body $body `
                     -SmtpServer "smtp.office365.com" `
                     -Port 587 `
                     -UseSsl `
                     -Credential (Get-Credential)
}

