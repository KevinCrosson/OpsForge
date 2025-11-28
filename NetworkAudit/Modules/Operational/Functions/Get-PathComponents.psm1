function Get-PathComponents {
    <#
    .SYNOPSIS
        Returns key components of a file or folder path as a hashtable.

    .DESCRIPTION
        This function extracts and returns the following components from a given path:
        - Parent:     The directory containing the file or folder
        - Leaf:       The final element of the path (file or folder name)
        - LeafBase:   The name without its extension
        - Extension:  The file extension (including the dot)

        It is useful for CI/CD pipelines, cleanup scripts, changelog generation, and
        any task that requires structured path analysis.

    .PARAMETER Path
        The full path to a file or folder. Can be relative or absolute.

    .OUTPUTS
        [hashtable] with keys: Parent, Leaf, LeafBase, Extension

    .EXAMPLE
        $info = Get-PathComponents -Path "C:\Logs\Cleanup\old.log"
        $info.LeafBase  # Returns "old"
        $info.Extension # Returns ".log"
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$Path
    )

    begin {
        # Initialize output collection if used in pipeline
        $results = @()
    }

    process {
        if (-not (Test-Path $Path)) {
            Write-Warning "Path not found: $Path"
            return
        }

        try {
            # Build the hashtable of path components
            $components = @{
                Parent     = Split-Path -Path $Path -Parent
                Leaf       = Split-Path -Path $Path -Leaf
                LeafBase   = Split-Path -Path $Path -LeafBase
                Extension  = Split-Path -Path $Path -Extension
            }

            # Output the result
            $results += $components
        } catch {
            Write-Error "Failed to parse path components for '$Path': $_"
        }
    }

    end {
        # Return single hashtable or array depending on input
        if ($results.Count -eq 1) {
            return $results[0]
        } else {
            return $results
        }
    }
}