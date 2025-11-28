# launch-buildmate.ps1 — Launches Buildmate setup and diagnostics with logging and error handling

# 📁 Define the root path of your Buildmate project
$projectPath = "C:\Users\cross\OneDrive\Documents\Projects\BuildMate_App\buildmate"

# 📝 Define the path for the launcher log file
$logFile = Join-Path $projectPath "logs\launcher\launcher_log.txt"

# 📂 Ensure the logs/launcher folder exists
$logDir = Split-Path $logFile
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force
}

# 🕒 Start log entry
Add-Content $logFile "`n==== Buildmate Launcher Started at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ===="

# 🧪 Check if virtual environment is active
if ($env:VIRTUAL_ENV) {
    Add-Content $logFile "[INFO] Virtual environment is already active: $env:VIRTUAL_ENV"
} else {
    # 🔄 Try to activate the virtual environment
    $venvPath = Join-Path $projectPath "venv\Scripts\Activate.ps1"
    if (Test-Path $venvPath) {
        try {
            & $venvPath
            Add-Content $logFile "[INFO] Activated virtual environment"
        } catch {
            Add-Content $logFile "[ERROR] Failed to activate virtual environment: $_"
        }
    } else {
        Add-Content $logFile "[ERROR] venv activation script not found at $venvPath"
    }
}

# ▶️ Run manage-deps.ps1 to install dependencies
$depsScript = Join-Path $projectPath "scripts\manage-deps.ps1"
if (Test-Path $depsScript) {
    try {
        powershell -ExecutionPolicy Bypass -File $depsScript
        Add-Content $logFile "[INFO] Ran manage-deps.ps1 successfully"
    } catch {
        Add-Content $logFile "[ERROR] manage-deps.ps1 failed: $_"
    }
} else {
    Add-Content $logFile "[WARN] manage-deps.ps1 not found"
}

# ▶️ Run diagnose-buildmate.ps1 to verify environment
$diagScript = Join-Path $projectPath "scripts\diagnose-buildmate.ps1"
if (Test-Path $diagScript) {
    try {
        powershell -ExecutionPolicy Bypass -File $diagScript
        Add-Content $logFile "[INFO] Ran diagnose-buildmate.ps1 successfully"
    } catch {
        Add-Content $logFile "[ERROR] diagnose-buildmate.ps1 failed: $_"
    }
} else {
    Add-Content $logFile "[WARN] diagnose-buildmate.ps1 not found"
}

# ✅ Final log entry
Add-Content $logFile "==== Buildmate Launcher Completed at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ===="