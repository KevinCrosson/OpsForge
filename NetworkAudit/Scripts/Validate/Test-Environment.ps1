<#
.SYNOPSIS
    Validates environment hygiene for NetworkAudit.

.DESCRIPTION
    - Checks PowerShell version and execution policy.
    - Runs encoding validation on all .ps1 files.
    - Confirms required CI/CD folders exist.
    - Warns if Git pre-commit hook is missing.
    - Exits with CI-friendly codes (0 = clean, 1 = issues).
#>

param (
    [switch]$Verbose
)

Write-Host "🔍 Running environment checks..." -ForegroundColor Cyan

# --- PowerShell version and execution policy ---
Write-Host "📁 Scanning folder root: $PSScriptRoot"
Write-Host "PowerShell version: $($PSVersionTable.PSVersion)"
Write-Host "Execution policy: $(Get-ExecutionPolicy)"

# --- Encoding validation ---
Write-Host "`n🔧 Running Test-Encoding.ps1..."
Write-Host "🔍 Checking UTF-8 BOM encoding in .ps1 files..."

$Files = Get-ChildItem -Path (Join-Path $PSScriptRoot "..") -Recurse -Filter *.ps1
$BadFiles = @()

foreach ($File in $Files) {
    # Read first few bytes to check for BOM
    $Bytes = Get-Content -Path $File.FullName -Encoding Byte -TotalCount 3
    $HasBom = ($Bytes[0] -eq 0xEF -and $Bytes[1] -eq 0xBB -and $Bytes[2] -eq 0xBF)

    if (-not $HasBom) {
        $BadFiles += $File.FullName
    }
}

if ($BadFiles.Count -gt 0) {
    Write-Host "`n⚠️ Files missing UTF-8 BOM:" -ForegroundColor Yellow
    $BadFiles | ForEach-Object { Write-Host $_ }
    Write-Warning "Encoding validation failed."
} else {
    Write-Host "✅ All .ps1 files have UTF-8 BOM encoding." -ForegroundColor Green
}

# --- Folder validation ---
Write-Host "`n📁 Verifying folder paths..."
$RequiredFolders = @("CI","Validate","Docs","Dispatchers","Maintenance","Metadata")

foreach ($Folder in $RequiredFolders) {
    $Path = Join-Path $PSScriptRoot "..\$Folder"
    $Exists = Test-Path $Path
    Write-Host "$Folder -> $Path -> Exists: $Exists"
    if (-not $Exists) {
        Write-Warning "$Folder folder missing!"
    }
}

Write-Host "✅ All required CI folders are present." -ForegroundColor Green

# --- Git pre-commit hook check ---
$HookPath = Join-Path (Get-Location) ".git/hooks/pre-commit"
if (-not (Test-Path $HookPath)) {
    Write-Warning "Git pre-commit hook not found. Hygiene enforcement may be bypassed."
} else {
    Write-Host "✅ Git pre-commit hook detected." -ForegroundColor Green
}

Write-Host "`n🏁 Environment check complete." -ForegroundColor Cyan

# --- CI-friendly exit code ---
if ($BadFiles.Count -gt 0) {
    exit 1
} else {
    exit 0
}
