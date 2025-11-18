<#
.SYNOPSIS
  Converts a metadata hashtable into a Markdown-formatted README string.

.DESCRIPTION
  This function takes a hashtable containing project metadata (e.g., name, version, author, license)
  and returns a Markdown-formatted string suitable for README.md generation. It is used by
  Export-MetadataFiles.ps1 and CI workflows to ensure consistent documentation.

.PARAMETER Metadata
  A hashtable containing keys like Project, Version, Author, License, LastUpdated, and Description.

.EXAMPLE
  $readme = ConvertToMarkdown -Metadata $metadata
  Set-Content -Path "README.md" -Value $readme
#>

function ConvertToMarkdown {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [hashtable]$Metadata
    )

    # Extract individual fields from the metadata hashtable
    $project     = $Metadata["Project"]
    $version     = $Metadata["Version"]
    $author      = $Metadata["Author"]
    $license     = $Metadata["License"]
    $lastUpdated = $Metadata["LastUpdated"]
    $description = $Metadata["Description"]

    # Construct the Markdown content using a here-string
    $markdown = @"
# $project

**Version:** $version  
**Author:** $author  
**License:** $license  
**Last Updated:** $lastUpdated

---

$description
"@

    # Return the formatted Markdown string
    return $markdown
}