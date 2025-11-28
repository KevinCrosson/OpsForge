<#
.SYNOPSIS
  Extracts the most recent version section from CHANGELOG.md and outputs it as release notes.

.PARAMETER OutputPath
  Optional path to write the release notes to a file.
#>

param (
    [string]$OutputPath = "$PSScriptRoot\..\Release-Notes.md"
)

$changelogPath = "$PSScriptRoot\..\CHANGELOG.md"
if (-not (Test-Path $changelogPath)) {
    Write-Error "CHANGELOG.md not found"
    exit 1
}

$lines = Get-Content $changelogPath
$start = ($lines | Select-String "^## \[" | Select-Object -First 1).LineNumber
$next = ($lines | Select-String "^## \[" | Select-Object -Skip 1 -First 1).LineNumber

if (-not $start) {
    Write-Error "No version section found in CHANGELOG.md"
    exit 1
}

$end = if ($next) { $next - 1 } else { $lines.Count - 1 }
$section = $lines[($start - 1)..$end]

$section | Out-File $OutputPath -Encoding UTF8
Write-Host "Release notes written to: $OutputPath"
