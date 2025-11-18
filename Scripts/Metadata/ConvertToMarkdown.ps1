<#
.SYNOPSIS
Renders README.md from metadata.

.DESCRIPTION
Takes structured metadata and writes a Markdown README file.
Supports dry-run preview and verbose logging.
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [hashtable]$Metadata,
    [Parameter(Mandatory = $true)]
    [string]$OutputPath,
    [switch]$DryRun,
    [switch]$Verbose
)

$md = @()
$md += "# NetworkAudit"
$md += "**Version:** $($Metadata.Version)"
$md += "**Generated:** $($Metadata.Timestamp)"
$md += "**Modules Included:** $($Metadata.ModuleCount)"
$md += ""
$md += "## Module Summary"
$md += "| Name | Purpose | Path | Version | Author |"
$md += "|------|---------|------|---------|--------|"

foreach ($mod in $Metadata.Modules) {
    $md += "| $($mod.Name) | $($mod.Description) | $($mod.Path) | $($mod.Version) | $($mod.Author) |"
}

$md += ""
$md += "## Folder Structure"
$md += "See `Docs/FolderStructure.png` for visual layout."
$md += ""
$md += "## Usage"
$md += "Run `Dispatch-All.ps1` for full diagnostics or `Dispatch-QuickCheck.ps1` for fast scan."
$md += ""
$md += "## License"
$md += "Licensed under MIT. See `LICENSE.txt`."

if ($DryRun) {
    $md -join "`n" | Write-Output
    return $true
}

try {
    $md -join "`n" | Set-Content -Path $OutputPath -Encoding UTF8
    return $true
} catch {
    Write-Error "Failed to write README.md: $_"
    return $false
}
