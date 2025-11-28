<#
.SYNOPSIS
  Appends a changelog entry to CHANGELOG.md.

.DESCRIPTION
  Adds a timestamped entry under the specified version heading.

.PARAMETER Message
  The changelog message to record.

.PARAMETER Version
  Optional version label (default: 'unreleased').
#>

param (
    [string]$Message,
    [string]$Version = "unreleased"
)

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$entry = "`n## [$Version] - $timestamp`n- $Message"
Add-Content -Path "C:\.PS\NetworkAudit\CHANGELOG.md" -Value $entry
Write-Host "Changelog updated."
