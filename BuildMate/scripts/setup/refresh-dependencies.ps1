# refresh-dependencies.ps1 — Sets up Buildmate environment or refreshes dependencies based on --quick flag

param (
    [switch]$Quick  # If set, skips folder creation, venv setup, and pip-tools install
)

# 🕒 Timestamp for logs and backups
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

# 📁 Define Buildmate root and setup log path
$projectPath = "C:\Users\cross\OneDrive\Documents\Projects\BuildMate_App\buildmate"
$setupLogPath = Join-Path $projectPath "logs\setup\setup_log.txt"

# ✅ Start setup log
Add-Content $setupLogPath "`n==== Buildmate Refresh Started at $timestamp ===="

# 🧭 If not in quick mode, create folders and set up venv
if (-not $Quick) {
    # 📂 Create required folders
    $foldersToCreate = @(
        "scripts", "logs\launcher", "logs\deps", "logs\diagnostics", "logs\setup", "backup"
    )
    foreach ($folder in $foldersToCreate) {
        $fullPath = Join-Path $projectPath $folder
        if (-not (Test-Path $fullPath)) {
            New-Item -ItemType Directory -Path $fullPath -Force
        }
    }

    # 🧪 Create virtual environment if missing
    $venvPath = Join-Path $projectPath "venv"
    if (-not (Test-Path $venvPath)) {
        try {
            python -m venv $venvPath
            Add-Content $setupLogPath "[INFO] Created virtual environment at $venvPath"
        } catch {
            Add-Content $setupLogPath "[ERROR] Failed to create virtual environment: $_"
            Write-Host "Virtual environment creation failed. See log for details."
            exit 1
        }
    } else {
        Add-Content $setupLogPath "[INFO] Virtual environment already exists"
    }

    # 🧠 Activate venv and install pip-tools
    $activateScript = Join-Path $venvPath "Scripts\Activate.ps1"
    if (Test-Path $activateScript) {
        try {
            & $activateScript
            Add-Content $setupLogPath "[INFO] Activated virtual environment"

            pip install pip-tools 2>&1 | Tee-Object -FilePath $setupLogPath -Append
            Add-Content $setupLogPath "[INFO] Installed pip-tools"
        } catch {
            Add-Content $setupLogPath "[ERROR] Failed to activate venv or install pip-tools: $_"
            Write-Host "pip-tools install failed. See log for details."
            exit 1
        }
    } else {
        Add-Content $setupLogPath "[ERROR] Activate.ps1 not found at $activateScript"
        Write-Host "Activation script missing. See log for details."
        exit 1
    }

    # 🔍 Check pip-tools version
    try {
        $pipToolsVersion = pip show pip-tools
        if ($pipToolsVersion) {
            $versionLine = ($pipToolsVersion | Select-String "Version").Line
            Add-Content $setupLogPath "[INFO] pip-tools version: $versionLine"
        } else {
            Add-Content $setupLogPath "[WARN] pip-tools not found after install"
        }
    } catch {
        Add-Content $setupLogPath "[ERROR] Error checking pip-tools version: $_"
    }
} else {
    Add-Content $setupLogPath "[INFO] Quick mode enabled — skipping folder and venv setup"
}

# 🔒 Run lock-requirements.ps1
$lockScript = Join-Path $projectPath "scripts\lock-requirements.ps1"
if (Test-Path $lockScript) {
    try {
        powershell -ExecutionPolicy Bypass -File $lockScript
        Add-Content $setupLogPath "[INFO] Ran lock-requirements.ps1 successfully"
    } catch {
        Add-Content $setupLogPath "[ERROR] lock-requirements.ps1 failed: $_"
        Write-Host "Locking failed. See log for details."
    }
} else {
    Add-Content $setupLogPath "[WARN] lock-requirements.ps1 not found"
}

# 📦 Run manage-deps.ps1
$depsScript = Join-Path $projectPath "scripts\manage-deps.ps1"
if (Test-Path $depsScript) {
    try {
        powershell -ExecutionPolicy Bypass -File $depsScript
        Add-Content $setupLogPath "[INFO] Ran manage-deps.ps1 successfully"
    } catch {
        Add-Content $setupLogPath "[ERROR] manage-deps.ps1 failed: $_"
        Write-Host "Dependency install failed. See log for details."
    }
} else {
    Add-Content $setupLogPath "[WARN] manage-deps.ps1 not found"
}

# ✅ Final log entry
Add-Content $setupLogPath "==== Buildmate Refresh Completed at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ===="

