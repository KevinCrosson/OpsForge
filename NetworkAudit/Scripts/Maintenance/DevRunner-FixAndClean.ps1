<#
.SYNOPSIS
  DevRunner task: Fix broken imports, delete empty folders, and remove duplicate files.
  Supports dry-run mode and logs all actions to categorized subfolders.

.PARAMETER DryRun
  If set, previews changes without modifying files.
#>

param (
    [switch]$DryRun = $false
)

# --- Setup paths and log folders ---
$root = "C:\.PS\NetworkAudit"
$devLogDir = "$root\Logs\DevRunner"
$cleanupLogDir = "$root\Logs\Cleanup"

# Ensure log folders exist
foreach ($dir in @($devLogDir, $cleanupLogDir)) {
    if (-not (Test-Path $dir)) {
        New-Item -Path $dir -ItemType Directory -Force | Out-Null
    }
}

$devLogPath = "$devLogDir\DevRunner-FixAndClean.log"
$cleanupLogPath = "$cleanupLogDir\CleanEmptyAndDuplicateFolders.log"
$mode = if ($DryRun) { 'DryRun' } else { 'Live' }

Add-Content -Path $devLogPath -Value "`n[$(Get-Date)] Starting DevRunner ($mode)"

# --- Initialize counters ---
$fixCount = 0
$emptyCount = 0
$duplicateCount = 0

# --- Fix Broken Imports ---
$replacements = @{
    'Modules\\NetworkAudit\\Generate-AllMetadata.psm1' = 'Modules\Operational\Functions\Get-ProjectMetadata.psm1'
    'Modules\\NetworkAudit\\ConvertToMarkdown.psm1'    = 'Modules\Operational\Functions\ConvertToMarkdown.psm1'
    'C:\\.PS\\modules\\NetworkAudit\\Register-NetworkAuditTask.psm1' = 'Modules\Operational\Functions\Register-NetworkAuditTask.psm1'
    'C:\\.PS\\modules\\NetworkAudit\\Purge-OldLogs.psm1'             = 'Modules\Operational\Functions\Purge-OldLogs.psm1'
    '\$commonRoot\\Convert-Timestamp.psm1' = 'Modules\Operational\Functions\Convert-Timestamp.psm1'
    '\$loggingRoot\\Write-LogEntry.psm1'   = 'Modules\Operational\Functions\Write-LogEntry.psm1'
}

$files = Get-ChildItem -Path $root -Recurse -Include *.ps1, *.psm1
foreach ($file in $files) {
    $text = Get-Content $file.FullName -Raw
    $lines = $text -split "`n"
    $modified = $false

    for ($i = 0; $i -lt $lines.Length; $i++) {
        foreach ($pattern in $replacements.Keys) {
            if ($lines[$i] -match [regex]::Escape($pattern)) {
                $replacement = $replacements[$pattern]
                $escapedReplacement = $replacement -replace "'", "''"

                # Inject comment and fixed import on separate lines
                $lines[$i]     = "# BROKEN IMPORT: replaced $pattern with $replacement"
                $lines[$i + 1] = "Import-Module `'$escapedReplacement`'"
                $i++
                $modified = $true
                $fixCount++

                if ($DryRun) {
                    Write-Host "DRY-RUN: Would fix import in $($file.FullName)"
                    Add-Content -Path $devLogPath -Value "DRY-RUN: $($file.FullName) ÃƒÆ'Ã†â€(TM)Ãƒâ€šÃ‚Â¢ÃƒÆ'Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚Â ÃƒÆ'Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ $replacement"
                } else {
                    Add-Content -Path $devLogPath -Value "FIXED: $($file.FullName) ÃƒÆ'Ã†â€(TM)Ãƒâ€šÃ‚Â¢ÃƒÆ'Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚Â ÃƒÆ'Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ $replacement"
                }

                break
            }
        }
    }

    if ($modified -and -not $DryRun) {
        $updated = $lines -join "`n"
        Set-Content -Path $file.FullName -Value $updated
        Write-Host "Fixed imports in $($file.FullName)"
    }
}

# --- Delete Empty Folders ---
$emptyDirs = Get-ChildItem -Path $root -Recurse -Directory | Where-Object {
    @(Get-ChildItem -Path $_.FullName -Recurse -Force -ErrorAction SilentlyContinue).Count -eq 0
}

foreach ($dir in $emptyDirs) {
    $emptyCount++
    if ($DryRun) {
        Write-Host "DRY-RUN: Would delete empty folder: $($dir.FullName)"
        Add-Content -Path $cleanupLogPath -Value "DRY-RUN: Empty folder ÃƒÆ'Ã†â€(TM)Ãƒâ€šÃ‚Â¢ÃƒÆ'Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚Â ÃƒÆ'Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ $($dir.FullName)"
    } else {
        Remove-Item -Path $dir.FullName -Force -Recurse
        Write-Host "Deleted empty folder: $($dir.FullName)"
        Add-Content -Path $cleanupLogPath -Value "Deleted: Empty folder ÃƒÆ'Ã†â€(TM)Ãƒâ€šÃ‚Â¢ÃƒÆ'Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚Â ÃƒÆ'Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ $($dir.FullName)"

        # Recreate Logs\Cleanup if it was deleted
        if ($dir.FullName -eq $cleanupLogDir -and -not (Test-Path $cleanupLogDir)) {
            New-Item -Path $cleanupLogDir -ItemType Directory -Force | Out-Null
        }
    }
}

# --- Delete Duplicate Files ---
$hashTable = @{}
$duplicates = @()

Get-ChildItem -Path $root -Recurse -File | ForEach-Object {
    try {
        $hash = Get-FileHash -Path $_.FullName -Algorithm SHA256
        if ($hashTable.ContainsKey($hash.Hash)) {
            $duplicates += $_
        } else {
            $hashTable[$hash.Hash] = $_.FullName
        }
    } catch {
        Write-Warning "Failed to hash: $($_.FullName)"
    }
}

foreach ($file in $duplicates) {
    $duplicateCount++
    if ($DryRun) {
        Write-Host "DRY-RUN: Would delete duplicate file: $($file.FullName)"
        Add-Content -Path $cleanupLogPath -Value "DRY-RUN: Duplicate file ÃƒÆ'Ã†â€(TM)Ãƒâ€šÃ‚Â¢ÃƒÆ'Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚Â ÃƒÆ'Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ $($file.FullName)"
    } else {
        Remove-Item -Path $file.FullName -Force
        Write-Host "Deleted duplicate file: $($file.FullName)"
        Add-Content -Path $cleanupLogPath -Value "Deleted: Duplicate file ÃƒÆ'Ã†â€(TM)Ãƒâ€šÃ‚Â¢ÃƒÆ'Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚Â ÃƒÆ'Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ $($file.FullName)"
    }
}

# --- Summary ---
Add-Content -Path $devLogPath -Value "`nSummary:"
Add-Content -Path $devLogPath -Value "Fixed imports: $fixCount"

Add-Content -Path $cleanupLogPath -Value "`nSummary:"
Add-Content -Path $cleanupLogPath -Value "Deleted empty folders: $emptyCount"
Add-Content -Path $cleanupLogPath -Value "Deleted duplicate files: $duplicateCount"

Write-Host "DevRunner-FixAndClean completed."
Write-Host "Summary:"
Write-Host "  - Fixed imports: $fixCount"
Write-Host "  - Deleted empty folders: $emptyCount"
Write-Host "  - Deleted duplicate files: $duplicateCount"
Write-Host "Logs saved to:"
Write-Host "  - $devLogPath"
Write-Host "  - $cleanupLogPath"



