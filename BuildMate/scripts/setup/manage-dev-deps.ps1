# manage-dev-deps.ps1 — Installs dev dependencies and verifies key tools

# 🕒 Timestamp for logging
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# 📁 Define paths
$projectPath = "C:\Users\cross\OneDrive\Documents\Projects\BuildMate_App\buildmate"
$requirementsFile = Join-Path $projectPath "requirements\locked-requirements-dev.txt"
$logFile = Join-Path $projectPath "logs\deps\dev_deps_log.txt"

# ✅ Start log entry
Add-Content $logFile "`n==== Dev Dependency Install Started at $timestamp ===="

# 🔍 Check if requirements file exists
if (-not (Test-Path $requirementsFile)) {
    Add-Content $logFile "[ERROR] locked-requirements-dev.txt not found at $requirementsFile"
    Write-Host "Missing dev lock file. See log for details."
    exit 1
}

# 📦 Install dev dependencies
try {
    pip install -r $requirementsFile 2>&1 | Tee-Object -FilePath $logFile -Append
    Add-Content $logFile "[INFO] Installed dev dependencies from locked-requirements-dev.txt"
} catch {
    Add-Content $logFile "[ERROR] pip install failed: $_"
    Write-Host "Dev dependency install failed. See log for details."
    exit 1
}

# 🔍 Verify key tools
$toolsToCheck = @("black", "flake8", "pytest", "pip-compile")
foreach ($tool in $toolsToCheck) {
    try {
        $version = & $tool --version
        Add-Content $logFile "[INFO] $tool version: $version"
    } catch {
        Add-Content $logFile "[ERROR] $tool not found or failed to run"
        Write-Host "$tool verification failed. See log for details."
    }
}

# ✅ Final log entry
Add-Content $logFile "==== Dev Dependency Install Completed at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ===="

