<#
.SYNOPSIS
CLI wrapper to run the full metadata export pipeline.

.DESCRIPTION
This script wraps Export-MetadataFiles.ps1 and forwards optional parameters like -DryRun and -Verbose.
It simplifies local testing and CI/CD integration by providing a single entry point for metadata generation,
README rendering, version syncing, and changelog updates.

.EXAMPLE
.\Run-Metadata.ps1 -DryRun -Verbose
#>

[CmdletBinding()]
param (
    [switch]$DryRun,
    [switch]$Verbose
)

# Resolve root directory relative to this script
$ScriptPath = $MyInvocation.MyCommand.Path
$Root = Split-Path -Path $ScriptPath -Parent

# Resolve path to Export-MetadataFiles.ps1
$ExportScript = Join-Path -Path $Root -ChildPath "Export-MetadataFiles.ps1"

if (-not (Test-Path $ExportScript)) {
    Write-Error "Export-MetadataFiles.ps1 not found at: $ExportScript"
    exit 1
}

# Build argument list dynamically
$ArgsList = @()
if ($DryRun)   { $ArgsList += "-DryRun" }
if ($Verbose)  { $ArgsList += "-Verbose" }

# Log invocation
Write-Host "`n[+] Running Export-MetadataFiles.ps1..." -ForegroundColor Cyan
Write-Host "    Path: $ExportScript"
if ($ArgsList.Count -gt 0) {
    Write-Host "    Args: $($ArgsList -join ' ')" -ForegroundColor Gray
}

# Invoke the export script with forwarded parameters
& $ExportScript @ArgsList

# Capture exit code
if ($LASTEXITCODE -ne 0) {
    Write-Error "Metadata export failed with exit code $LASTEXITCODE"
    exit $LASTEXITCODE
}

Write-Host "[OK] Metadata pipeline completed successfully." -ForegroundColor Green

