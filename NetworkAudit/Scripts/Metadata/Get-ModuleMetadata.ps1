<#
.SYNOPSIS
    Extracts metadata from PowerShell modules in the Modules folder.

.DESCRIPTION
    Scans each module folder under Modules/, reads the .psd1 manifest if present,
    and returns a hashtable of module names and their version, author, and description.

.PARAMETER Root
    Root directory of the repository.

.EXAMPLE
    Get-ModuleMetadata -Root "C:\.PS\NetworkAudit"

.NOTES
    Dispatcher: Scripts/Metadata/Get-ModuleMetadata.ps1
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$Root
)

$ModulesPath = Join-Path $Root "Modules"
$Metadata = @{}

# Loop through each module folder
Get-ChildItem -Path $ModulesPath -Directory | ForEach-Object {
    $ModuleName = $_.Name
    $ManifestPath = Join-Path $_.FullName "$ModuleName.psd1"

    if (Test-Path $ManifestPath) {
        try {
            $Manifest = Import-PowerShellDataFile -Path $ManifestPath
            $Metadata[$ModuleName] = @{
                Version     = $Manifest.ModuleVersion
                Author      = $Manifest.Author
                Description = $Manifest.Description
            }
        } catch {
            $Metadata[$ModuleName] = "Error reading manifest"
        }
    } else {
        $Metadata[$ModuleName] = "No manifest found"
    }
}

return $Metadata