param([switch]$DryRun)

$LogFolder = "$PSScriptRoot\..\..\Logs\Monitor\System"
New-Item -ItemType Directory -Path $LogFolder -Force | Out-Null
$TimeStamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$LogFile = "$LogFolder\System_$TimeStamp.log"

if ($DryRun) {
    Write-Host "[DryRun] Would log system changes to $LogFile"
} else {
    Get-WinEvent -LogName 'System' |
        Where-Object { $_.Id -in 6005, 6006, 7045 } | Select-Object TimeCreated, Id, Message |
        Sort-Object TimeCreated -Descending | Select-Object -First 20 |
        Format-Table -AutoSize | Out-String | Tee-Object -FilePath $LogFile
}
