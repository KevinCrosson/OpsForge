<#
.SYNOPSIS
    Dispatcher script to generate and export metadata.

.DESCRIPTION
    Combines Generate-AllMetadata.ps1 and Export-MetadataFiles.ps1 into a single dispatcher task.
    Supports dry-run and verbose output for CI/CD integration.

.PARAMETER Root
    Root directory of the repository.

.PARAMETER DryRun
    Simulates export without writing files.

.PARAMETER Verbose
    Enables detailed output.

.EXAMPLE
    Run-Metadata -Root "C:\.PS\NetworkAudit" -Verbose

.NOTES
    Dispatcher: Scripts/Dispatchers/Metadata/Run-Metadata.ps1
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$Root,

    [switch]$DryRun,
    [switch]$Verbose
)

# Import dependencies
. "$Root\Scripts\Metadata\Generate-AllMetadata.ps1"
. "$Root\Scripts\Metadata\Export-MetadataFiles.ps1"

# Generate metadata
$Metadata = Generate-AllMetadata -Root $Root

# Export to markdown files
Export-MetadataFiles -Metadata $Metadata -Root $Root -DryRun:$DryRun -Verbose:$Verbose