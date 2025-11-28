<#
.SYNOPSIS
    Generates metadata from folder structure and script counts.

.DESCRIPTION
    Scans subfolders under Scripts/, counts .ps1 files in each, and builds a metadata hashtable.
    Adds timestamp and version info for documentation and CI tracking.

.PARAMETER Root
    Root directory of the repository.

.EXAMPLE
    Generate-AllMetadata -Root "C:\.PS\NetworkAudit"

.NOTES
    Dispatcher: Scripts/Dispatchers/Metadata/Generate-AllMetadata.ps1
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$Root
)

# Initialize metadata hashtable
$Metadata = @{}

# Define path to Scripts folder
$ScriptsPath = Join-Path $Root "Scripts"

# Get all subfolders under Scripts/
$Categories = Get-ChildItem -Path $ScriptsPath -Directory

# Count .ps1 files in each category folder
foreach ($Category in $Categories) {
    $Count = (Get-ChildItem -Path $Category.FullName -Filter *.ps1 -Recurse).Count
    $Metadata[$Category.Name] = "$Count scripts"
}

# Add timestamp and version info
$Metadata["Generated"] = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
$Metadata["Version"]   = "v1.0.0"

# Return metadata hashtable
return $Metadata