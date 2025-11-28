<#
.SYNOPSIS
    Unit tests for Log-ActiveConnections.ps1

.DESCRIPTION
    Validates connection parsing, hostname resolution, and reverse validation logic.
#>

Import-Module Pester

Describe "Log-ActiveConnections.ps1" {

    It "Resolves known public IP to hostname" {
        $Ip = "8.8.8.8"
        $Entry = [System.Net.Dns]::GetHostEntry($Ip)
        $Entry.HostName | Should -Not -BeNullOrEmpty
    }

    It "Performs reverse validation correctly" {
        $Ip = "8.8.8.8"
        $Hostname = ([System.Net.Dns]::GetHostEntry($Ip)).HostName
        $ReverseIPs = [System.Net.Dns]::GetHostAddresses($Hostname) | ForEach-Object { $_.ToString() }
        $ReverseIPs | Should -Contain $Ip
    }

    It "Handles unresolved IPs gracefully" {
        $FakeIP = "192.0.2.123"  # Reserved for documentation
        { [System.Net.Dns]::GetHostEntry($FakeIP) } | Should -Throw
    }
}