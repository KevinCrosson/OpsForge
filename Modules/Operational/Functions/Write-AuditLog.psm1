function Write-AuditLog {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Action,     # e.g., "TCP Connection", "Scan", "Alert"

        [Parameter(Mandatory)]
        [string]$Target,     # e.g., "192.168.1.5:443 → 23.45.67.89:80"

        [Parameter(Mandatory)]
        [string]$Details,    # e.g., "Protocol=TCP; Process=1234; External IP detected"

        [string]$LogPath = "$PSScriptRoot\..\Logs\NetworkAudit.log",  # Default path, override allowed

        [switch]$DryRun       # If set, prints instead of writing to file
    )

    # Format timestamp for log entry
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    # Assemble log entry
    $logEntry = "$timestamp | $Action | $Target | $Details"

    # Dry-run mode: preview without writing
    if ($DryRun) {
        Write-Host "[DryRun] $logEntry"
        return
    }

    # Ensure log folder exists
    $logFolder = Split-Path -Path $LogPath -Parent
    if (-not (Test-Path $logFolder)) {
        New-Item -Path $logFolder -ItemType Directory -Force | Out-Null
    }

    # Optional: Rotate log if over 5MB (commented out for manual activation)
    # $maxSizeMB = 5
    # if ((Test-Path $LogPath) -and ((Get-Item $LogPath).Length -gt ($maxSizeMB * 1MB))) {
    #     $archivePath = "$LogPath.old"
    #     Move-Item -Path $LogPath -Destination $archivePath -Force
    # }

    # Write entry to log file
    $logEntry | Add-Content -Path $LogPath -Encoding UTF8
}