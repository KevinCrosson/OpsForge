# launch-dependency-workflow.ps1 — Bundled launcher for locking and installing prod + dev dependencies

# 🕒 Timestamp for logging
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# 📁 Define paths
$projectPath = "C:\Users\cross\OneDrive\Documents\Projects\BuildMate_App\buildmate"
$logFile = Join-Path $projectPath "logs\setup\bundled_launcher_log.txt"

# ✅ Start log entry
Add-Content $logFile "`n==== Bundled Dependency Workflow Started at $timestamp ===="

# 🔒 Lock production requirements
try {
    pip-compile requirements\requirements.in --output-file requirements\locked-requirements.txt --strip-extras 2>&1 | Tee-Object -FilePath $logFile -Append
    Add-Content $logFile "[INFO] Locked production requirements"
} catch {
    Add-Content $logFile "[ERROR] Failed to lock production requirements: $_"
    Write-Host "Production locking failed. See log for details."
}

# 🔒 Lock dev requirements
try {
    pip-compile requirements\requirements-dev.in --output-file requirements\locked-requirements-dev.txt --strip-extras 2>&1 | Tee-Object -FilePath $logFile -Append
    Add-Content $logFile "[INFO] Locked development requirements"
} catch {
    Add-Content $logFile "[ERROR] Failed to lock development requirements: $_"
    Write-Host "Dev locking failed. See log for details."
}

# 📦 Install production dependencies
try {
    pip install -r requirements\locked-requirements.txt 2>&1 | Tee-Object -FilePath $logFile -Append
    Add-Content $logFile "[INFO] Installed production dependencies"
} catch {
    Add-Content $logFile "[ERROR] Failed to install production dependencies: $_"
    Write-Host "Production install failed. See log for details."
}

# 📦 Install dev dependencies
try {
    pip install -r requirements\locked-requirements-dev.txt 2>&1 | Tee-Object -FilePath $logFile -Append
    Add-Content $logFile "[INFO] Installed development dependencies"
} catch {
    Add-Content $logFile "[ERROR] Failed to install development dependencies: $_"
    Write-Host "Dev install failed. See log for details."
}

# 🔍 Verify key tools
$toolsToCheck = @("flask", "pytest", "black", "flake8", "pip-compile")
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
Add-Content $logFile "==== Bundled Workflow Completed at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ===="

