<#
.SYNOPSIS
  Updates Import-Module paths from old to new structure.

.DESCRIPTION
  Replaces 'Modules\Operational\Functions\' with 'Modules\Operational\Functions\' in all .ps1 and .psm1 files.
  Supports dry-run mode to preview changes without modifying files.

.PARAMETER DryRun
  If set, previews changes without writing to disk.
#>

param (
    [switch]$DryRun = $false
)

$root = "C:\.PS\NetworkAudit"
$old = 'Modules\Operational\Functions\'
$new = 'Modules\Operational\Functions\'

# Get all script and module files
$files = Get-ChildItem -Path $root -Recurse -Include *.ps1, *.psm1

foreach ($file in $files) {
    $text = Get-Content $file.FullName -Raw
    if ($text -like "*$old*") {
        $updated = $text -replace [regex]::Escape($old), $new
        if ($DryRun) {
            Write-Host "DRY-RUN: Would update $($file.FullName)"
        } else {
            Set-Content -Path $file.FullName -Value $updated
            Write-Host "Updated: $($file.FullName)"
        }
    }
}

