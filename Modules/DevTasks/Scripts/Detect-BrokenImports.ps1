<#
.SYNOPSIS
  Detects and optionally comments out broken Import-Module statements.

.DESCRIPTION
  Scans all .ps1 and .psm1 files for Import-Module statements.
  If the referenced .psm1 file doesn't exist, logs the issue and optionally comments it out.

.PARAMETER DryRun
  If set, previews broken imports without modifying files.
#>

param (
    [switch]$DryRun = $false
)

$root = "C:\.PS\NetworkAudit"
$log = "$root\Logs\BrokenImports.log"
New-Item -Path $log -ItemType File -Force | Out-Null

# Scan all script and module files
Get-ChildItem -Path $root -Recurse -Include *.ps1, *.psm1 | ForEach-Object {
    $lines = Get-Content $_.FullName
    $changed = $false

    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match 'Import-Module\s+["''](.+?\.psm1)["'']') {
            $path = $matches[1]
            $resolved = Join-Path (Split-Path $_.FullName -Parent) $path
            if (-not (Test-Path $resolved)) {
                $msg = "BROKEN IMPORT: $($_.FullName): Line $($i+1): $($lines[$i])"
                Write-Host $msg -ForegroundColor Red
                Add-Content -Path $log -Value $msg

                if (-not $DryRun) {
                    $lines[$i] = "# BROKEN: $($lines[$i])"
                    $changed = $true
                }
            }
        }
    }

    if ($changed -and -not $DryRun) {
        Set-Content -Path $_.FullName -Value $lines
        Write-Host "Commented broken imports in: $($_.FullName)"
    }
}
