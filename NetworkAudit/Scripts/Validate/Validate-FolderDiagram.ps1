<#
.SYNOPSIS
Validates that FolderStructure.png is up to date with the latest file changes.

.DESCRIPTION
Compares the last modified time of Docs/FolderStructure.png with the latest Git commit affecting tracked files.
Fails if the diagram is older than the most recent change.

.EXAMPLE
.\Validate-FolderDiagram.ps1
#>

$Root = (git rev-parse --show-toplevel)
$DiagramPath = Join-Path $Root "Docs/FolderStructure.png"

if (-not (Test-Path $DiagramPath)) {
    Write-Error "FolderStructure.png not found. Run Generate-FolderDiagram.ps1 first."
    exit 1
}

$DiagramTime = (Get-Item $DiagramPath).LastWriteTimeUtc
$LatestChange = git log -1 --pretty=format:"%ct" | ForEach-Object { [DateTimeOffset]::FromUnixTimeSeconds($_).UtcDateTime }

if ($LatestChange -gt $DiagramTime) {
    Write-Error "Folder diagram is outdated. Last change: $LatestChange, diagram: $DiagramTime"
    exit 1
} else {
    Write-Host "[PASS] Folder diagram is up to date."
}