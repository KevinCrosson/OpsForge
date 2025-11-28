function Get-FolderTree {
    <#
    .SYNOPSIS
        Recursively returns a visual tree of the folder structure.

    .DESCRIPTION
        This function walks through the folder hierarchy starting from the given path,
        and returns a tree-style representation of subfolders. Useful for documentation,
        onboarding, and CI visibility.

    .PARAMETER Path
        The root folder to scan.

    .PARAMETER Indent
        Internal use only. Controls indentation level during recursion.

    .EXAMPLE
        Get-FolderTree -Path "$Root\Modules"
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Path,

        [string]$Indent = ""
    )

    # Step 1: Validate path
    if (-not (Test-Path $Path)) {
        Write-Warning "Path not found: $Path"
        return
    }

    # Step 2: Output current folder name
    Write-Output "$Indent+ $(Split-Path -Path $Path -Leaf)"

    # Step 3: Recurse into subfolders
    Get-ChildItem -Path $Path -Directory | ForEach-Object {
        Get-FolderTree -Path $_.FullName -Indent ("$Indent  ")
    }
}