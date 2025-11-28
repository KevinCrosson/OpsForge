# manage-deps.ps1 — Installs dependencies from locked-requirements.txt with logging and verification

# 📁 Define the root path of your Buildmate project
$projectPath = "C:\Users\cross\OneDrive\Documents\Projects\BuildMate_App\buildmate"

# 📝 Define the path for the dependency log file
$logFile = Join-Path $projectPath "logs\deps\deps_log.txt"

# 📂 Ensure the logs/deps folder exists
$logDir = Split-Path $logFile
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force
}

# 🕒 Start log entry with timestamp
Add-Content $logFile "`n==== Dependency Install Started at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ===="

# 📄 Define path to locked requirements file
$lockedPath = Join-Path $projectPath "requirements\locked-requirements.txt"

# ❌ Check if locked-requirements.txt exists
if (-not (Test-Path $lockedPath)) {
    Add-Content $logFile "[ERROR] locked-requirements.txt not found at $lockedPath"
    Write-Host "locked-requirements.txt not found. Run lock-requirements.ps1 first."
    exit 1
}

# ✅ Install dependencies using pip and log output
try {
    pip install -r $lockedPath 2>&1 | Tee-Object -FilePath $logFile -Append
    Add-Content $logFile "[INFO] Dependencies installed from locked-requirements.txt"
} catch {
    Add-Content $logFile "[ERROR] Failed to install dependencies: $_"
    Write-Host "Installation failed. See log for details."
    exit 1
}

# 🔍 Verify key packages are installed
foreach ($pkg in @("flask", "pytest", "requests")) {
    try {
        $check = pip show $pkg
        if ($check) {
            Add-Content $logFile "[INFO] $pkg is installed"
        } else {
            Add-Content $logFile "[WARN] $pkg not found"
        }
    } catch {
        # 🛠 Enhanced error message with timestamp
        Add-Content $logFile "[ERROR] [$pkg] Check failed at $(Get-Date -Format 'HH:mm:ss'): $_"
    }
}

# ✅ Final log entry
Add-Content $logFile "==== Dependency Install Completed at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ===="