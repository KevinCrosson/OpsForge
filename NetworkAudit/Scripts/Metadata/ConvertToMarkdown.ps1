<#
.SYNOPSIS
    Converts a hashtable of metadata into markdown format.

.DESCRIPTION
    Iterates over key-value pairs in a hashtable and formats each as a markdown line.
    Used by Export-MetadataFiles.ps1 to generate documentation blocks for README.md and CHANGELOG.md.

.PARAMETER Metadata
    Hashtable containing metadata fields and values.

.EXAMPLE
    ConvertToMarkdown -Metadata @{ Author = "Kevin"; Version = "1.0.0" }

.NOTES
    Utility script for formatting metadata into markdown.
#>

param (
    [Parameter(Mandatory = $true)]
    [hashtable]$Metadata
)

# Initialize markdown output array
$Markdown = @()

# Format each key-value pair as "**Key**: Value"
foreach ($Key in $Metadata.Keys) {
    $Line = "**$Key**: $($Metadata[$Key])"
    $Markdown += $Line
}

# Return markdown string joined by newlines
return $Markdown -join "`n"