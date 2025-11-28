@echo off
REM LaunchBuildmate.bat — One-click launcher for Buildmate with logging and PYTHONPATH fix

REM 📁 Set the absolute path to your Buildmate project root
set "PROJECT_PATH=C:\Users\cross\OneDrive\Documents\Projects\BuildMate_App\buildmate"

REM 📝 Set the path for the log file
set "LOG_FILE=%PROJECT_PATH%\logs\launcher\buildmate_log.txt"

REM 🕒 Log the start time
echo ==== Launch started at %DATE% %TIME% ==== >> "%LOG_FILE%"

REM 📂 Change to the Buildmate project directory
cd /d "%PROJECT_PATH%"
echo [INFO] Changed directory to %PROJECT_PATH% >> "%LOG_FILE%"

REM 🧪 Activate the virtual environment if it exists
if exist "%PROJECT_PATH%\venv\Scripts\activate.bat" (
    call "%PROJECT_PATH%\venv\Scripts\activate.bat"
    echo [INFO] Virtual environment activated. >> "%LOG_FILE%"
) else (
    echo [WARN] Virtual environment not found. Run python -m venv venv. >> "%LOG_FILE%"
)

REM 🧭 Set PYTHONPATH to the Buildmate root so Python can find the 'app' package
set PYTHONPATH=%PROJECT_PATH%
echo [INFO] PYTHONPATH set to %PYTHONPATH% >> "%LOG_FILE%"

REM 📦 Run dependency setup script using PowerShell silently
if exist "%PROJECT_PATH%\scripts\scripts\manage-deps.ps1" (
    powershell -ExecutionPolicy Bypass -File "%PROJECT_PATH%\scripts\scripts\manage-deps.ps1" >> "%LOG_FILE%" 2>&1
    echo [INFO] Ran scripts\scripts\manage-deps.ps1 >> "%LOG_FILE%"
) else (
    echo [INFO] scripts\scripts\manage-deps.ps1 not found. Skipping dependency install. >> "%LOG_FILE%"
)

REM 🧪 Run tests with pytest if available
where pytest >nul 2>nul
if %errorlevel%==0 (
    echo [INFO] Running tests... >> "%LOG_FILE%"
    pytest tests/ --disable-warnings --maxfail=3 >> "%LOG_FILE%" 2>&1
    echo [INFO] Tests completed. >> "%LOG_FILE%"
) else (
    echo [WARN] pytest not found. Run pip install pytest. >> "%LOG_FILE%"
)

REM 💻 Launch VS Code silently
where code >nul 2>nul
if %errorlevel%==0 (
    start "" /b code .
    echo [INFO] VS Code launched. >> "%LOG_FILE%"
) else (
    echo [WARN] VS Code not found in PATH. >> "%LOG_FILE%"
)

REM 🐚 Launch Git Bash silently in the project folder
set "GIT_BASH=C:\Program Files\Git\git-bash.exe"
if exist "%GIT_BASH%" (
    start "" /b "%GIT_BASH%" --cd="%PROJECT_PATH%"
    echo [INFO] Git Bash launched. >> "%LOG_FILE%"
) else (
    echo [WARN] Git Bash not found at %GIT_BASH%. >> "%LOG_FILE%"
)

REM 🕒 Log the completion time
echo ==== Launch completed at %DATE% %TIME% ==== >> "%LOG_FILE%"
