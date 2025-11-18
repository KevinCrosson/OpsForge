<#
.SYNOPSIS
  Deletes all empty folders recursively from the project root.

.DESCRIPTION
  Scans all subdirectories and removes those with no files or folders inside.
  Supports dry-run mode to preview deletions.

.PARAMETER DryRun
  If set, previews deletions without removing folders.
#>

param (
    [switch]$DryRun = $false
)

$root = "C:\.PS\NetworkAudit"
$folders = Get-ChildItem -Path $root -Recurse -Directory

foreach ($folder in $folders) {
    $items = Get-ChildItem -Path $folder.FullName -Force
    if ($items.Count -eq 0) {
        if ($DryRun) {
            Write-Host "DRY-RUN: Would remove $($folder.FullName)"
        } else {
            Remove-Item $folder.FullName -Force
            Write-Host "Removed: $($folder.FullName)"
        }
    }
}
