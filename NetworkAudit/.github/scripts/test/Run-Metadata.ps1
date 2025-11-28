<#
.SYNOPSIS
    CLI wrapper to run Generate-AllMetadata from the NetworkAudit module.
.DESCRIPTION
    Imports the module and executes the metadata generation logic with verbose output.
#>

$ModulePath = "$PSScriptRoot\..\Modules\Operational\Functions\Generate-AllMetadata.psm1"

if (-not (Test-Path $ModulePath)) {
    Write-Error "Module not found: $ModulePath"
    exit 1
}

Import-Module $ModulePath -Force
Write-Host "Module imported: $ModulePath"

try {
    Generate-AllMetadata -Verbose
    Write-Host "Metadata generation completed."
} catch {
    Write-Error "Error during metadata generation: $_"
    exit 1
}

