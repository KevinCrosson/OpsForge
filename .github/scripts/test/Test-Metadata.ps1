<#
.SYNOPSIS
    Preview metadata and rendered README.md without writing to disk.
.DESCRIPTION
    Imports metadata and markdown modules, generates metadata, and renders README in dry-run mode.
#>

# BROKEN: # BROKEN: Import-Module "$PSScriptRoot\..\..\Operational\Functions\Get-ProjectMetadata.psm1" -Force
# BROKEN: # BROKEN: Import-Module "$PSScriptRoot\..\..\Operational\Functions\ConvertToMarkdown.psm1" -Force


$Metadata = Generate-AllMetadata -Verbose
Convert-ReadmeFromTemplate -Metadata $Metadata -DryRun
