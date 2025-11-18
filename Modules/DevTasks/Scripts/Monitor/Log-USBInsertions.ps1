param([switch]$DryRun)

$LogFolder = "$PSScriptRoot\..\..\Logs\Monitor\USB"
New-Item -ItemType Directory -Path $LogFolder -Force | Out-Null
$TimeStamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$LogFile = "$LogFolder\USB_$TimeStamp.log"

if ($DryRun) {
    Write-Host "[DryRun] Would log USB insertions to $LogFile"
} else {
    Get-WinEvent -LogName 'Microsoft-Windows-DriverFrameworks-UserMode/Operational' |
        Where-Object { $_.Id -eq 2003 } | Select-Object TimeCreated, Message |
        Sort-Object TimeCreated -Descending | Select-Object -First 10 |
        Format-Table -AutoSize | Out-String | Tee-Object -FilePath $LogFile
}
