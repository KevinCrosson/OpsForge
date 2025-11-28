<#
.SYNOPSIS
    Validator script to enforce UTF-8 BOM hygiene in PowerShell files.

.DESCRIPTION
    - Recursively scans all .ps1 files in the repository.
    - Detects files missing UTF-8 BOM encoding.
    - Logs results to Scripts\Validate\Logs\EncodingCheck.log.
    - Exits with code 1 if any files fail (so Git pre-commit hook blocks commit).
    - Exits with code 0 if all files pass (commit proceeds).
#>

param (
    [string]$ScanPath = (Join-Path (Get-Location).Path ".."),  # Default: repo root
    [switch]$Verbose
)

# --- Setup ---
Write-Host "🔍 Checking UTF-8 BOM encoding in .ps1 files..."
Write-Host "📁 Scanning path: $ScanPath"

# Ensure Logs folder exists
$LogDir = Join-Path (Get-Location).Path "Logs"
if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir | Out-Null
}

$LogFile = Join-Path $LogDir "EncodingCheck.log"

# --- Collect all .ps1 files ---
$Files = Get-ChildItem -Path $ScanPath -Recurse -Include *.ps1 -File

# --- Track failures ---
$FilesMissingBom = @()

foreach ($File in $Files) {
    try {
        # Read raw bytes
        $Bytes = [System.IO.File]::ReadAllBytes($File.FullName)

        # UTF-8 BOM is EF BB BF
        $HasBom = $Bytes.Length -ge 3 -and
                  $Bytes[0] -eq 0xEF -and
                  $Bytes[1] -eq 0xBB -and
                  $Bytes[2] -eq 0xBF

        if (-not $HasBom) {
            Write-Host "⚠️ Files missing UTF-8 BOM:`n$($File.FullName)"
            $FilesMissingBom += $File.FullName
        }
        elseif ($Verbose) {
            Write-Host "✅ BOM present: $($File.FullName)"
        }
    }
    catch {
        Write-Warning "Error reading file $($File.FullName): $_"
    }
}

# --- Log results ---
$Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$LogEntry = @"
[$Timestamp] Encoding check complete.
Files scanned: $($Files.Count)
Files missing BOM: $($FilesMissingBom.Count)
"@
Add-Content -Path $LogFile -Value $LogEntry

# --- Enforcement ---
if ($FilesMissingBom.Count -gt 0) {
    Write-Host "❌ BOM hygiene failed. Commit blocked."
    exit 1
}
else {
    Write-Host "✅ BOM hygiene passed."
    exit 0
}


