<#
.SYNOPSIS
  Scans all .ps1 and .psm1 files for broken Import-Module paths and replaces them with updated paths.
  Supports dry-run mode, auto-commenting, and logs all actions to a file.

.DESCRIPTION
  This script is designed for CI/CD and manual use. It identifies known broken import paths,
  replaces them with updated paths, and optionally comments out the original line for traceability.
  All actions are logged to FixBrokenImports.log in the Logs folder.

.PARAMETER DryRun
  If set, previews changes without modifying files.
#>

param (
    [switch]$DryRun = $false
)

# Define root directory for scanning
$root = "C:\.PS\NetworkAudit"

# Define log file path
$logPath = "$root\Logs\FixBrokenImports.log"

# Determine mode using PowerShell 5.1-compatible logic
if ($DryRun) {
    $mode = 'DryRun'
} else {
    $mode = 'Live'
}

# Log the start of the operation
Add-Content -Path $logPath -Value "`n[$(Get-Date)] Starting Fix-BrokenImports ($mode)"

# Define known broken import paths and their replacements
$replacements = @{
# BROKEN IMPORT: replaced Modules\\NetworkAudit\\Generate-AllMetadata.psm1 with Modules\Operational\Functions\Get-ProjectMetadata.psm1
# BROKEN: # BROKEN: Import-Module 'Modules\Operational\Functions\Get-ProjectMetadata.psm1'
# BROKEN: # BROKEN: Import-Module 'Modules\Operational\Functions\Get-ProjectMetadata.psm1'
# BROKEN: # BROKEN: Import-Module 'Modules\Operational\Functions\Get-ProjectMetadata.psm1'
# BROKEN: # BROKEN: Import-Module 'Modules\Operational\Functions\Get-ProjectMetadata.psm1'
# BROKEN: # BROKEN: Import-Module 'Modules\Operational\Functions\Get-ProjectMetadata.psm1'
# BROKEN: # BROKEN: Import-Module 'Modules\Operational\Functions\Get-ProjectMetadata.psm1'
# BROKEN: # BROKEN: Import-Module 'Modules\Operational\Functions\Get-ProjectMetadata.psm1'
# BROKEN: # BROKEN: Import-Module 'Modules\Operational\Functions\Get-ProjectMetadata.psm1'
# BROKEN IMPORT: replaced Modules\\NetworkAudit\\ConvertToMarkdown.psm1 with Modules\Operational\Functions\ConvertToMarkdown.psm1
# BROKEN: # BROKEN: Import-Module 'Modules\Operational\Functions\ConvertToMarkdown.psm1'
# BROKEN: # BROKEN: Import-Module 'Modules\Operational\Functions\ConvertToMarkdown.psm1'
# BROKEN: # BROKEN: Import-Module 'Modules\Operational\Functions\ConvertToMarkdown.psm1'
# BROKEN: # BROKEN: Import-Module 'Modules\Operational\Functions\ConvertToMarkdown.psm1'
# BROKEN: # BROKEN: Import-Module 'Modules\Operational\Functions\ConvertToMarkdown.psm1'
# BROKEN: # BROKEN: Import-Module 'Modules\Operational\Functions\ConvertToMarkdown.psm1'
# BROKEN: # BROKEN: Import-Module 'Modules\Operational\Functions\ConvertToMarkdown.psm1'
# BROKEN: # BROKEN: Import-Module 'Modules\Operational\Functions\ConvertToMarkdown.psm1'
# BROKEN IMPORT: replaced C:\\.PS\\modules\\NetworkAudit\\Register-NetworkAuditTask.psm1 with Modules\Operational\Functions\Register-NetworkAuditTask.psm1
# BROKEN: # BROKEN: Import-Module 'Modules\Operational\Functions\Register-NetworkAuditTask.psm1'
# BROKEN: # BROKEN: Import-Module 'Modules\Operational\Functions\Register-NetworkAuditTask.psm1'
# BROKEN: # BROKEN: Import-Module 'Modules\Operational\Functions\Register-NetworkAuditTask.psm1'
# BROKEN: # BROKEN: Import-Module 'Modules\Operational\Functions\Register-NetworkAuditTask.psm1'
# BROKEN: # BROKEN: Import-Module 'Modules\Operational\Functions\Register-NetworkAuditTask.psm1'
# BROKEN: # BROKEN: Import-Module 'Modules\Operational\Functions\Register-NetworkAuditTask.psm1'
# BROKEN: # BROKEN: Import-Module 'Modules\Operational\Functions\Register-NetworkAuditTask.psm1'
# BROKEN: # BROKEN: Import-Module 'Modules\Operational\Functions\Register-NetworkAuditTask.psm1'
# BROKEN IMPORT: replaced C:\\.PS\\modules\\NetworkAudit\\Purge-OldLogs.psm1 with Modules\Operational\Functions\Purge-OldLogs.psm1
# BROKEN: # BROKEN: Import-Module 'Modules\Operational\Functions\Purge-OldLogs.psm1'
# BROKEN: # BROKEN: Import-Module 'Modules\Operational\Functions\Purge-OldLogs.psm1'
# BROKEN: # BROKEN: Import-Module 'Modules\Operational\Functions\Purge-OldLogs.psm1'
# BROKEN: # BROKEN: Import-Module 'Modules\Operational\Functions\Purge-OldLogs.psm1'
# BROKEN: # BROKEN: Import-Module 'Modules\Operational\Functions\Purge-OldLogs.psm1'
# BROKEN: # BROKEN: Import-Module 'Modules\Operational\Functions\Purge-OldLogs.psm1'
# BROKEN: # BROKEN: Import-Module 'Modules\Operational\Functions\Purge-OldLogs.psm1'
# BROKEN: # BROKEN: Import-Module 'Modules\Operational\Functions\Purge-OldLogs.psm1'
# BROKEN IMPORT: replaced \$commonRoot\\Convert-Timestamp.psm1 with Modules\Operational\Functions\Convert-Timestamp.psm1
# BROKEN: # BROKEN: Import-Module 'Modules\Operational\Functions\Convert-Timestamp.psm1'
# BROKEN: # BROKEN: Import-Module 'Modules\Operational\Functions\Convert-Timestamp.psm1'
# BROKEN: # BROKEN: Import-Module 'Modules\Operational\Functions\Convert-Timestamp.psm1'
# BROKEN: # BROKEN: Import-Module 'Modules\Operational\Functions\Convert-Timestamp.psm1'
# BROKEN: # BROKEN: Import-Module 'Modules\Operational\Functions\Convert-Timestamp.psm1'
# BROKEN: # BROKEN: Import-Module 'Modules\Operational\Functions\Convert-Timestamp.psm1'
# BROKEN: # BROKEN: Import-Module 'Modules\Operational\Functions\Convert-Timestamp.psm1'
# BROKEN: # BROKEN: Import-Module 'Modules\Operational\Functions\Convert-Timestamp.psm1'
# BROKEN IMPORT: replaced \$loggingRoot\\Write-LogEntry.psm1 with Modules\Operational\Functions\Write-LogEntry.psm1
# BROKEN: # BROKEN: Import-Module 'Modules\Operational\Functions\Write-LogEntry.psm1'
# BROKEN: # BROKEN: Import-Module 'Modules\Operational\Functions\Write-LogEntry.psm1'
# BROKEN: # BROKEN: Import-Module 'Modules\Operational\Functions\Write-LogEntry.psm1'
# BROKEN: # BROKEN: Import-Module 'Modules\Operational\Functions\Write-LogEntry.psm1'
# BROKEN: # BROKEN: Import-Module 'Modules\Operational\Functions\Write-LogEntry.psm1'
# BROKEN: # BROKEN: Import-Module 'Modules\Operational\Functions\Write-LogEntry.psm1'
# BROKEN: # BROKEN: Import-Module 'Modules\Operational\Functions\Write-LogEntry.psm1'
# BROKEN: # BROKEN: Import-Module 'Modules\Operational\Functions\Write-LogEntry.psm1'
}

# Recursively find all .ps1 and .psm1 files under the root
$files = Get-ChildItem -Path $root -Recurse -Include *.ps1, *.psm1

foreach ($file in $files) {
    # Read file content as a single string
    $text = Get-Content $file.FullName -Raw

    # Split into lines for line-by-line processing
    $lines = $text -split "`n"
    $modified = $false

    # Scan each line for broken import patterns
    for ($i = 0; $i -lt $lines.Length; $i++) {
        foreach ($pattern in $replacements.Keys) {
            if ($lines[$i] -match [regex]::Escape($pattern)) {
                $replacement = $replacements[$pattern]

                # Escape single quotes to prevent parser errors
                $escapedReplacement = $replacement -replace "'", "''"

                # Build replacement line safely
                $fixed = "Import-Module `'$escapedReplacement`'"
                $commented = "# BROKEN IMPORT: $($lines[$i])"
                $lines[$i] = "$commented`n$fixed"
                $modified = $true

                # Log the change
                if ($DryRun) {
                    Write-Host "DRY-RUN: Would fix import in $($file.FullName)"
                    Add-Content -Path $logPath -Value "DRY-RUN: $($file.FullName) Ã¢â€ â€™ $replacement"
                } else {
                    Add-Content -Path $logPath -Value "FIXED: $($file.FullName) Ã¢â€ â€™ $replacement"
                }
            }
        }
    }

    # If changes were made and not in dry-run mode, write updated content back to file
    if ($modified -and -not $DryRun) {
        $updated = $lines -join "`n"
        Set-Content -Path $file.FullName -Value $updated
        Write-Host "Fixed imports in $($file.FullName)"
    }
}

# Final status message
Write-Host "Ã¢Å“â€¦ Fix-BrokenImports completed. Log saved to: $logPath"








