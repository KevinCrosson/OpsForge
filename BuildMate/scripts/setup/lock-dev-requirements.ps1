# lock-dev-requirements.ps1 — Generates locked-requirements-dev.txt from requirements-dev.in

# 🕒 Timestamp for logging
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# 📁 Define paths
$projectPath = "C:\Users\cross\OneDrive\Documents\Projects\BuildMate_App\buildmate"
$inputFile = Join-Path $projectPath "requirements\requirements-dev.in"
$outputFile = Join-Path $projectPath "requirements\locked-requirements-dev.txt"
$logFile = Join-Path $projectPath "logs\setup\lock-dev-log.txt"

# ✅ Start log entry
Add-Content $logFile "`n==== Dev Lock Started at $timestamp ===="

# 🔍 Check if input file exists
if (-not (Test-Path $inputFile)) {
    Add-Content $logFile "[ERROR] requirements-dev.in not found at $inputFile"
    Write-Host "Missing requirements-dev.in. See log for details."
    exit 1
}

# 🧪 Check if pip-tools is available
try {
    $pipToolsVersion = pip show pip-tools
    if (-not $pipToolsVersion) {
        Add-Content $logFile "[ERROR] pip-tools not installed in active environment"
        Write-Host "pip-tools not found. Activate your venv and run: pip install pip-tools"
        exit 1
    }
} catch {
    Add-Content $logFile "[ERROR] Failed to check pip-tools: $_"
    Write-Host "Error checking pip-tools. See log for details."
    exit 1
}

# 🔒 Run pip-compile to generate dev lock file
try {
    pip-compile $inputFile --output-file $outputFile 2>&1 | Tee-Object -FilePath $logFile -Append
    Add-Content $logFile "[INFO] Successfully generated locked-requirements-dev.txt"
} catch {
    Add-Content $logFile "[ERROR] pip-compile failed: $_"
    Write-Host "Locking failed. See log for details."
    exit 1
}

# ✅ Final log entry
Add-Content $logFile "==== Dev Lock Completed at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ===="

