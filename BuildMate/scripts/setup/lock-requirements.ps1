# lock-requirements.ps1 — Uses pip-compile to generate locked-requirements.txt from requirements.in

# 📁 Define project root and log file path
$projectPath = "C:\Users\cross\OneDrive\Documents\Projects\BuildMate_App\buildmate"
$logFile = Join-Path $projectPath "logs\locking\lock_log.txt"

# 📂 Ensure logs/locking folder exists
$logDir = Split-Path $logFile
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force
}

# 🕒 Start log entry
Add-Content $logFile "`n==== Locking Started at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ===="

# 📄 Define paths to input and output files
$inputFile = Join-Path $projectPath "requirements\requirements.in"
$outputFile = Join-Path $projectPath "requirements\locked-requirements.txt"

# ❌ Check if requirements.in exists
if (-not (Test-Path $inputFile)) {
    Add-Content $logFile "[ERROR] requirements.in not found at $inputFile"
    Write-Host "requirements.in not found. Create it before locking."
    exit 1
}

# ✅ Run pip-compile
try {
    pip-compile $inputFile --output-file $outputFile 2>&1 | Tee-Object -FilePath $logFile -Append
    Add-Content $logFile "[INFO] locked-requirements.txt generated successfully"
} catch {
    Add-Content $logFile "[ERROR] pip-compile failed: $_"
    Write-Host "Locking failed. See log for details."
    exit 1
}

# ✅ Final log entry
Add-Content $logFile "==== Locking Completed at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ===="