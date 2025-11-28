<#
.SYNOPSIS
    Repairs corrupted or non-standard symbols in PowerShell scripts.

.DESCRIPTION
    - Recursively scans all .ps1 files under the specified root.
    - Loads replacement rules from SymbolMap.json (external file).
    - Replaces problematic Unicode symbols with safe ASCII equivalents.
    - Writes changes back with UTF-8 BOM encoding (for CI/CD compatibility).
    - Logs all actions to Scripts\Maintenance\Logs\SymbolFix.log.
    - Skips clean files but logs them as [SKIPPED] for traceability.
    - Supports dry-run mode for CI validation without modifying files.

.PARAMETER Root
    The root folder to scan (defaults to current directory).

.PARAMETER DryRun
    If specified, no files are modified; actions are logged only.

.PARAMETER Verbose
    Prints detailed output to the console.
#>

param (
    [string]$Root = ".",
    [switch]$DryRun,
    [switch]$Verbose
)

# --- Setup log path ---
$LogDir  = Join-Path $Root "Scripts\Maintenance\Logs"
if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}
$LogPath = Join-Path $LogDir "SymbolFix.log"

# --- Start log banner ---
$Banner = "=== Symbol Repair Run: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ==="
Add-Content -Path $LogPath -Value $Banner
Write-Verbose $Banner

# --- Load symbol map from JSON ---
$SymbolMapPath = Join-Path $Root "Scripts\Maintenance\SymbolMap.json"
if (-not (Test-Path $SymbolMapPath)) {
    Write-Error "SymbolMap.json not found at $SymbolMapPath"
    exit 1
}

# Convert JSON into a hashtable-like object
$SymbolMap = Get-Content $SymbolMapPath -Raw | ConvertFrom-Json

# --- Scan all .ps1 files recursively ---
$Files = Get-ChildItem -Path $Root -Recurse -Filter *.ps1

foreach ($File in $Files) {
    $Content  = Get-Content -Path $File.FullName -Raw
    $Original = $Content

    # Iterate over each key in the JSON map
    foreach ($Key in $SymbolMap.PSObject.Properties.Name) {
        $Value = $SymbolMap.$Key
        # Cast key to string before escaping (avoids errors with char codes)
        $Content = $Content -replace [regex]::Escape([string]$Key), $Value
    }

    if ($Content -ne $Original) {
        if ($DryRun) {
            # Dry-run: log what would be fixed
            Add-Content $LogPath "[FIXABLE] $($File.FullName)"
            Write-Verbose "Dry-run: would fix $($File.FullName)"
        } else {
            # Live repair: overwrite file with UTF-8 BOM encoding
            # PowerShell 7+ supports -Encoding UTF8BOM directly
            try {
                Set-Content -Path $File.FullName -Value $Content -Encoding UTF8BOM
            } catch {
                # Fallback for Windows PowerShell 5.1
                $Utf8BomEncoding = New-Object System.Text.UTF8Encoding($true)
                [System.IO.File]::WriteAllText($File.FullName, $Content, $Utf8BomEncoding)
            }

            Add-Content $LogPath "[FIXED] $($File.FullName)"
            Write-Verbose "Fixed $($File.FullName)"
        }
    } else {
        # File was already clean
        Add-Content $LogPath "[SKIPPED] $($File.FullName) (already clean)"
        Write-Verbose "Skipped $($File.FullName) (already clean)"
    }
}

# --- End of run ---
$Summary = "[DONE] Symbol repair complete. Log saved to $LogPath"
Add-Content $LogPath $Summary
Write-Host $Summary -ForegroundColor Cyan

# --- CI-friendly exit code ---
if ($DryRun) {
    # In dry-run mode, exit with 1 if any FIXABLE entries exist
    $FixableCount = (Select-String "\[FIXABLE\]" $LogPath).Count
    if ($FixableCount -gt 0) { exit 1 } else { exit 0 }
} else {
    exit 0
}
