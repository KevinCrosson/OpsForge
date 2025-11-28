param (
    [switch]$DryRun,
    [switch]$Verbose,
    [string]$LogRoot = "C:\NetworkAuditLogs"  # External log root
)

# Create timestamped subfolder for this run
$Timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$RunLogDir = Join-Path $LogRoot $Timestamp
if (-not (Test-Path $RunLogDir)) { New-Item -Path $RunLogDir -ItemType Directory | Out-Null }

function Write-VerboseLog {
    if ($Verbose) {
        Write-Host "[VERBOSE] $args" -ForegroundColor Cyan
    }

}

# Define known devices
$KnownDevices = @(
    @{ IP = "192.168.1.100"; MAC = "00-1a-2b-3c-4d-5e"; Name = "DVR" },
    @{ IP = "192.168.1.1";   MAC = "aa-bb-cc-dd-ee-ff"; Name = "Router" },
    @{ IP = "192.168.1.10";  MAC = "11-22-33-44-55-66"; Name = "PC" }
)

# Set external log paths
$ArpLogPath = Join-Path $RunLogDir "ArpLog.txt"
$TrafficLogPath = Join-Path $RunLogDir "TrafficLog.txt"

# --- ARP Monitoring ---
Log-Verbose "Scanning ARP table..."
$ArpOutput = arp -a | Where-Object { $_ -match "dynamic" }

$ArpResults = foreach ($line in $ArpOutput) {
    $parts = $line -split "\s+"
    if ($parts.Length -ge 3) {
        $IP = $parts[0]
        $MAC = $parts[1].ToLower()
        $Known = $KnownDevices | Where-Object { $_.IP -eq $IP -or $_.MAC -eq $MAC }

        [PSCustomObject]@{
            Timestamp = $Timestamp
            IPAddress = $IP
            MACAddress = $MAC
            Status = if ($Known) { "Known ($($Known.Name))" } else { "UNKNOWN" }
        }
    }
}

if (-not $DryRun) {
    $ArpResults | Format-Table | Out-String | Set-Content -Path $ArpLogPath
}
Log-Verbose "ARP log saved to $ArpLogPath"

# --- Wireshark Traffic Monitoring ---
$tsharkPath = "C:\Program Files\Wireshark\tshark.exe"
$pcapFile = "Logs\Traffic\capture.pcap"

if (Test-Path $pcapFile -and Test-Path $tsharkPath) {
    Log-Verbose "Parsing Wireshark capture..."
    $TrafficRaw = & "$tsharkPath" -r $pcapFile -q -z conv,tcp

    $TrafficResults = foreach ($line in $TrafficRaw) {
        if ($line -match "(\d+\.\d+\.\d+\.\d+)\s+<->\s+(\d+\.\d+\.\d+\.\d+)") {
            $IP1, $IP2 = $matches[1], $matches[2]
            $Known1 = $KnownDevices | Where-Object { $_.IP -eq $IP1 }
            $Known2 = $KnownDevices | Where-Object { $_.IP -eq $IP2 }

            [PSCustomObject]@{
                Timestamp = $Timestamp
                SourceIP = $IP1
                DestIP = $IP2
                Status = if ($Known1 -or $Known2) { "Known" } else { "UNKNOWN" }
            }
        }
    }

    if (-not $DryRun) {
        $TrafficResults | Format-Table | Out-String | Set-Content -Path $TrafficLogPath
    }
    Log-Verbose "Traffic log saved to $TrafficLogPath"
} else {
    Log-Verbose "Wireshark `.pcap` or `tshark.exe` not found. Skipping traffic analysis."
}
