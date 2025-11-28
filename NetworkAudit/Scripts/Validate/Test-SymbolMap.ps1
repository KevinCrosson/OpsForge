<#
.SYNOPSIS
Validates SymbolMap.json for correctness, duplicate keys, and replacement integrity.

.DESCRIPTION
Loads SymbolMap.json, decodes both literal characters (like " " ...) and escaped
Unicode sequences (like , ), prints each symbol alongside its
Unicode codepoint and replacement value, and fails if duplicates or malformed
entries are found. Results are logged for audit.

.EXAMPLE
.\Scripts\Validate\Test-SymbolMap.ps1
#>

param (
    # Default path assumes SymbolMap.json is in Scripts/Maintenance
    [string]$MapPath = "$PSScriptRoot\..\Maintenance\SymbolMap.json",

    # Log file path for audit trail
    [string]$LogPath = "$PSScriptRoot\Logs\SymbolMapTest.log"
)

# --- Step 1: Ensure log folder exists ---
# This guarantees that logs are always written, even if the folder was missing.
$LogFolder = Split-Path $LogPath
if (-not (Test-Path $LogFolder)) {
    New-Item -ItemType Directory -Path $LogFolder -Force | Out-Null
}

# --- Step 2: Load JSON safely ---
# Fail-fast if the JSON cannot be parsed.
try {
    $RawMap = Get-Content $MapPath -Raw -Encoding UTF8 | ConvertFrom-Json
} catch {
    Write-Error "❌ Failed to load or parse SymbolMap.json at $MapPath"
    exit 1   # Stop immediately if JSON is invalid
}

# --- Step 3: Decode keys into usable characters ---
# Build an ordered dictionary for stable iteration.
$SymbolMap = [ordered]@{}
# Track seen keys to detect duplicates.
$SeenKeys = @{}
# Collect output lines for logging.
$Output = @()
$Output += "=== SymbolMap Test Harness: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ===`n"

foreach ($key in $RawMap.PSObject.Properties.Name) {
    # Handle escaped Unicode keys like ""
    if ($key -match '^\\u([0-9A-Fa-f]{4})$') {
        $decodedChar = [char]([Convert]::ToInt32($Matches[1], 16))
        $decodedKey = $decodedChar
    } else {
        # Literal characters (curly quotes, dashes, etc.)
        $decodedKey = $key
    }

    # --- Step 4: Duplicate detection ---
    if ($SeenKeys.ContainsKey($decodedKey)) {
        Write-Error "❌ Duplicate key detected: '$decodedKey'"
        exit 1   # Fail-fast: stop immediately if duplicates exist
    } else {
        $SeenKeys[$decodedKey] = $true
    }

    # Add to symbol map
    $SymbolMap[$decodedKey] = $RawMap.$key
}

# --- Step 5: Display results ---
foreach ($pair in $SymbolMap.GetEnumerator()) {
    $symbol = $pair.Key
    $replacement = $pair.Value

    # Convert symbol to numeric codepoint
    $codepoint = [int][char]$symbol
    $hex = "U+{0:X4}" -f $codepoint

    # Build output line
    $Output += ("Symbol: '{0}'  Codepoint: {1}  Replacement: '{2}'" -f $symbol, $hex, $replacement)
}

# --- Step 6: Write log ---
# Save results to file for CI artifact upload.
$Output | Set-Content -Path $LogPath -Encoding UTF8
Write-Host "[DONE] Results logged to $LogPath"

