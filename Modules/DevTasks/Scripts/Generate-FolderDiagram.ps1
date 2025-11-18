function New-FolderDiagram {
    param (
        [string]$SourcePath,
        [string]$OutputPath
    )

    $lines = @()
    $lines += "# Folder Structure Diagram"
    $lines += ""

    function Get-FolderTree($Path, $Indent = "") {
        $name = Split-Path $Path -Leaf
        $lines += "$Indent- $name"

        Get-ChildItem -Path $Path -Directory | ForEach-Object {
            Walk-Folder $_.FullName "$Indent  "
        }
    }

    Walk-Folder $SourcePath
    $lines -join "`n" | Set-Content -Path $OutputPath -Encoding UTF8
}
