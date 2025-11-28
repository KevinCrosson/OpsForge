# setup-buildmate.ps1 — Initializes Buildmate environment, folders, venv, pip-tools, and runs lock + install

param ()

# 🕒 Timestamp for logs and backups
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

# 📁 Define Buildmate root and setup log path
$projectPath = "C:\Users\cross\OneDrive\Documents\Projects\BuildMate_App\buildmate"
$setupLogPath = Join-Path $projectPath "logs\setup\setup_log.txt"

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

# ✅ Start setup log
Add-Content $setupLogPath "`n==== Buildmate Setup Started at $timestamp ===="

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

        # 📦 Install pip-tools
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

# 📄 Move scripts to scripts/ and back them up
$scriptFiles = @("LaunchBuildmate.ps1", "manage-deps.ps1", "diagnose-buildmate.ps1", "lock-requirements.ps1")
foreach ($file in $scriptFiles) {
    $sourcePath = Join-Path $projectPath $file
    $targetPath = Join-Path $projectPath "scripts\$file"
    $backupName = "$file-$timestamp.bak"
    $backupPath = Join-Path $projectPath "backup\$backupName"

    if (Test-Path $sourcePath) {
        Copy-Item $sourcePath $backupPath -Force
        Move-Item $sourcePath $targetPath -Force
        Add-Content $setupLogPath "[INFO] Moved $file to scripts/, backup saved as $backupName"
    } else {
        Add-Content $setupLogPath "[WARN] File not found: $file"
    }
}

# 📝 Update launch-buildmate.bat to use scripts/manage-deps.ps1
$batPath = Join-Path $projectPath "launch-buildmate.bat"
$batBackupName = "LaunchBuildmate-$timestamp.bat"
$batBackupPath = Join-Path $projectPath "backup\$batBackupName"

if (Test-Path $batPath) {
    Copy-Item $batPath $batBackupPath -Force
    Add-Content $setupLogPath "[INFO] Backed up launch-buildmate.bat as $batBackupName"

    $batContent = Get-Content $batPath
    $updatedBat = $batContent -replace 'manage-deps\.ps1', 'scripts\manage-deps.ps1'
    Set-Content -Path $batPath -Value $updatedBat
    Add-Content $setupLogPath "[INFO] Updated launch-buildmate.bat to use scripts/manage-deps.ps1"
} else {
    Add-Content $setupLogPath "[WARN] launch-buildmate.bat not found"
}

# 🛠️ Update diagnose-buildmate.ps1 to log in logs/diagnostics/
$diagPath = Join-Path $projectPath "scripts\diagnose-buildmate.ps1"
if (Test-Path $diagPath) {
    $diagContent = Get-Content $diagPath
    $updatedDiag = $diagContent -replace 'buildmate_diag\.txt', 'logs\\diagnostics\\buildmate_diag.txt'
    Set-Content -Path $diagPath -Value $updatedDiag
    Add-Content $setupLogPath "[INFO] Updated diagnose-buildmate.ps1 to use logs/diagnostics/"
} else {
    Add-Content $setupLogPath "[WARN] diagnose-buildmate.ps1 not found in scripts/"
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
Add-Content $setupLogPath "==== Buildmate Setup Completed at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ===="





