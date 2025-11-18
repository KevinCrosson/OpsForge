<#
.SYNOPSIS
    Appends a new version entry to the changelog.
.DESCRIPTION
    Adds a timestamped version header and optional notes to Docs\CHANGELOG.md.
.PARAMETER Version
    The new version number (e.g., 1.3.0).
.PARAMETER Notes
    Optional bullet points or summary text.
#>

param (
    [Parameter(Mandatory)]
    [string]$Version,

    [string[]]$Notes
)

$ChangelogPath = "$PSScriptRoot\..\Docs\CHANGELOG.md"
$Timestamp = Get-Date -Format "yyyy-MM-dd"

$Entry = @()
$Entry += "`n## [$Version] - $Timestamp`n"

if ($Notes) {
    foreach ($Note in $Notes) {
        $Entry += "- $Note"
    }
} else {
    $Entry += "- No notes provided."
}

Add-Content -Path $ChangelogPath -Value $Entry
Write-Host "Changelog updated with version $Version" -ForegroundColor Cyan
