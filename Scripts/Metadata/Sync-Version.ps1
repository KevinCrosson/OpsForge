<#
.SYNOPSIS
Synchronizes version headers across all script files.

.DESCRIPTION
Reads the canonical version from VERSION.txt and updates version tags in all .ps1 and .psm1 files
under Scripts and Modules. Ensures consistency across metadata headers for release hygiene.

Supports dry-run mode and verbose logging.

.EXAMPLE
Sync-Version -Root "C:\NetworkAudit" -Version "1.2.3"
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$Root,

    [Parameter(Mandatory = $true)]
    [string]$Version,

    [switch]$DryRun,
    [switch]$Verbose
)

# Log start
Write-Host "`n[+] Syncing version tags to $Version..." -ForegroundColor Cyan
if ($DryRun) {
    Write-Host "[i] Dry-run mode enabled. No files will be modified." -ForegroundColor Yellow
}

# Step 1: Find all .ps1 and .psm1 files
$ScriptDirs = @("Scripts", "Modules")
$ScriptFiles = foreach ($dir in $ScriptDirs) {
    $Path = Join-Path $Root $dir
    if (Test-Path $Path) {
        Get-ChildItem -Path $Path -Recurse -Include *.ps1, *.psm1 -File
    }
}

if (-not $ScriptFiles) {
    Write-Warning "No script files found to update."
    return $false
}

# Step 2: Define regex pattern for version tag
$VersionPattern = '^\s*#\s*Version\s*:\s*(\d+\.\d+\.\d+)'

# Step 3: Iterate and update version tags
$UpdatedCount = 0
foreach ($File in $ScriptFiles) {
    $Content = Get-Content $File.FullName -Raw
    if ($Content -match $VersionPattern) {
        $OldVersion = $Matches[1]
        if ($OldVersion -ne $Version) {
            $NewContent = $Content -replace $VersionPattern, "# Version: $Version"
            if ($DryRun) {
                Write-Host "[DRY-RUN] Would update $($File.Name): $OldVersion Ã¢â€ â€™ $Version" -ForegroundColor Yellow
            } else {
                Set-Content -Path $File.FullName -Value $NewContent -Encoding UTF8
                Write-Host "[Ã¢Å“â€œ] Updated $($File.Name): $OldVersion Ã¢â€ â€™ $Version" -ForegroundColor Green
                $UpdatedCount++
            }
        } elseif ($Verbose) {
            Write-Host "[=] Skipped $($File.Name): already at $Version" -ForegroundColor Gray
        }
    } elseif ($Verbose) {
        Write-Host "[!] No version tag found in $($File.Name)" -ForegroundColor DarkGray
    }
}

# Final summary
Write-Host "`n[Ã¢Å“â€œ] Version sync complete. Files updated: $UpdatedCount" -ForegroundColor Cyan
return $true
