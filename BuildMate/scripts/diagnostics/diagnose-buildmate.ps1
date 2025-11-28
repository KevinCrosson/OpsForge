# diagnose-buildmate.ps1 — Verifies Buildmate environment setup with detailed logging

# 📁 Set the Buildmate root path
$projectPath = "C:\Users\cross\OneDrive\Documents\Projects\BuildMate_App\buildmate"

# 📂 Ensure diagnostics log folder exists
$diagFolder = Join-Path $projectPath "logs\diagnostics"
if (-not (Test-Path $diagFolder)) {
    New-Item -ItemType Directory -Path $diagFolder -Force
}

# Define log file path
$logFile = "logs\diagnostics\buildmate_diag.txt"

# Ensure the diagnostics folder exists
$logDir = Split-Path $logFile
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force
}

# Now it's safe to log
Add-Content $logFile "==== Buildmate Diagnostic Started at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ===="

# 🕒 Log the start time
Add-Content $logFile "==== Buildmate Diagnostic Started at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ===="

# ✅ Check if virtual environment is active
if ($env:VIRTUAL_ENV) {
    Add-Content $logFile "[INFO] Virtual environment is active: $env:VIRTUAL_ENV"
} else {
    Add-Content $logFile "[WARN] Virtual environment is NOT active. Activate it before running diagnostics."
}

# 🐍 Check if Python is available
if (Get-Command python -ErrorAction SilentlyContinue) {
    $pyVersion = python --version 2>&1
    Add-Content $logFile "[INFO] Python is available: $pyVersion"
} else {
    Add-Content $logFile "[ERROR] Python not found in PATH."
}

# 📦 Check if pip is available
if (Get-Command pip -ErrorAction SilentlyContinue) {
    $pipVersion = pip --version 2>&1
    Add-Content $logFile "[INFO] pip is available: $pipVersion"
} else {
    Add-Content $logFile "[WARN] pip not found. Trying python -m pip..."
    try {
        $pipAlt = python -m pip --version 2>&1
        Add-Content $logFile "[INFO] pip is accessible via python -m pip: $pipAlt"
    } catch {
        Add-Content $logFile "[ERROR] pip is not available by any method."
    }
}

# 📄 Check for requirements.txt
$reqPath = Join-Path $projectPath "requirements.txt"
if (Test-Path $reqPath) {
    Add-Content $logFile "[INFO] requirements.txt found."
} else {
    Add-Content $logFile "[WARN] requirements.txt NOT found."
}

# 🔍 Check if Flask is installed
try {
    python -c "import flask" 2>$null
    Add-Content $logFile "[INFO] Flask is installed."
} catch {
    Add-Content $logFile "[WARN] Flask is NOT installed."
}

# 🔍 Check if pytest is installed
try {
    python -c "import pytest" 2>$null
    Add-Content $logFile "[INFO] pytest is installed."
} catch {
    Add-Content $logFile "[WARN] pytest is NOT installed."
}

# 🕒 Log the completion time
Add-Content $logFile "==== Buildmate Diagnostic Completed at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ===="
