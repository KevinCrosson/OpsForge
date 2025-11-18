param([switch]$DryRun)

$LogFolder = "$PSScriptRoot\..\..\Logs\Monitor\Network"
New-Item -ItemType Directory -Path $LogFolder -Force | Out-Null
$TimeStamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$LogFile = "$LogFolder\Network_$TimeStamp.log"

if ($DryRun) {
    Write-Host "[DryRun] Would log active TCP connections to $LogFile"
} else {
    Get-NetTCPConnection | Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, State |
        Format-Table -AutoSize | Out-String | Tee-Object -FilePath $LogFile
}
