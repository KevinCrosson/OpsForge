# ============================================
# Scan-NetworkConnections.psm1
# ============================================
# Purpose:
#   - Return structured list of active TCP connections
#   - Resolve remote IPs to hostnames
#   - Flag trusted vs unverified connections
# ============================================

function Scan-NetworkConnections {
    param (
        [switch]$VerboseLog
    )

    # --- Define trusted domains ---
    $trustedPatterns = @(
        "*.microsoft.com",
        "*.akadns.net",
        "*.windows.com",
        "*.azure.com",
        "*.bing.com"
    )

    # --- Helper: Check if hostname matches trusted patterns ---
    function Is-TrustedHost {
        param ([string]$hostname)
        foreach ($pattern in $trustedPatterns) {
            if ($hostname -like $pattern) {
                return $true
            }
        }
        return $false
    }

    # --- Get active TCP connections ---
    $connections = Get-NetTCPConnection | Where-Object { $_.State -eq "Established" }

    $results = @()

    foreach ($conn in $connections) {
        $remoteIP   = $conn.RemoteAddress
        $remotePort = $conn.RemotePort
        $localPort  = $conn.LocalPort
        $protocol   = "TCP"

        # --- Attempt to resolve hostname ---
        try {
            $hostname = [System.Net.Dns]::GetHostEntry($remoteIP).HostName
        } catch {
            $hostname = "Unresolved"
        }

        # --- Determine trust status ---
        $isTrusted = Is-TrustedHost -hostname $hostname

        # --- Verbose output (optional) ---
        if ($VerboseLog) {
            $status = if ($isTrusted) { "Trusted" } else { "Unverified" }
            Write-Host "$status | $remoteIP:$remotePort | Hostname: $hostname"
        }

        # --- Add structured result ---
        $results += [PSCustomObject]@{
            RemoteIP    = $remoteIP
            RemotePort  = $remotePort
            LocalPort   = $localPort
            Hostname    = $hostname
            Protocol    = $protocol
            IsTrusted   = $isTrusted
        }
    }

    return $results
}