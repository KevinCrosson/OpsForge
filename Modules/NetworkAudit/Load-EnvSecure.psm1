# ============================================
# Module: Load-EnvSecure.psm1
# ============================================
# Purpose: Securely load environment variables from .env.enc using DPAPI
# Features:
#   - Dev-mode fallback to plaintext .env
#   - Required key validation
#   - Exponential backoff retry logic
#   - Verbose logging to file
# ============================================

function Load-EnvSecure {
    param (
        [string]$EncPath = "C:\.PS\Logs\NetworkAudit\.env.enc",         # Path to encrypted .env file
        [string]$PlainPath = "C:\.PS\Logs\NetworkAudit\.env",          # Path to plaintext .env (for dev mode)
        [string[]]$RequiredKeys = @(                                   # Keys that must be present
            "SMTP_SERVER", "SMTP_PORT", "EMAIL_FROM", "EMAIL_TO",
            "EMAIL_SUBJECT", "EMAIL_USERNAME", "EMAIL_PASSWORD"
        ),
        [switch]$DevMode,                                              # Use plaintext .env if available
        [switch]$VerboseLog,                                           # Enable logging
        [int]$MaxRetries = 3,                                          # Max retry attempts
        [int]$InitialDelayMs = 500                                     # Initial delay for exponential backoff
    )

    $logPath = "C:\.PS\Logs\NetworkAudit\EnvLoad.log"                  # Log file path
    $envVars = @{}                                                    # Hashtable to store parsed variables
    $success = $false                                                 # Flag for successful load
    $attempt = 0                                                      # Retry counter

    # --- Logging helper ---
    function Log {
        param ([string]$msg)
        if ($VerboseLog) {
            $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
            Add-Content -Path $logPath -Value "$timestamp - $msg"
        }
    }

    # --- Retry loop with exponential backoff ---
    while (-not $success -and $attempt -lt $MaxRetries) {
        try {
            $attempt++
            Log "Attempt $attempt: Starting environment load"

            # --- Dev-mode fallback ---
            if ($DevMode -and (Test-Path $PlainPath)) {
                Log "DevMode enabled — loading plaintext .env"
                $envText = Get-Content $PlainPath -Raw

            # --- Encrypted load ---
            } elseif (Test-Path $EncPath) {
                Log "Loading encrypted .env.enc"
                $encrypted = [System.IO.File]::ReadAllBytes($EncPath)

                $decrypted = [System.Security.Cryptography.ProtectedData]::Unprotect(
                    $encrypted,
                    $null,
                    [System.Security.Cryptography.DataProtectionScope]::CurrentUser
                )
                $envText = [System.Text.Encoding]::UTF8.GetString($decrypted)

            # --- No file found ---
            } else {
                throw "No .env file found at $EncPath or $PlainPath"
            }

            # --- Parse .env into hashtable ---
            $envText -split "`n" | ForEach-Object {
                if ($_ -match "^\s*#") { return }  # Skip comments
                $parts = $_ -split "=", 2
                if ($parts.Count -eq 2) {
                    $envVars[$parts[0].Trim()] = $parts[1].Trim()
                }
            }

            # --- Validate required keys ---
            $missing = $RequiredKeys | Where-Object { -not $envVars.ContainsKey($_) }
            if ($missing.Count -gt 0) {
                throw "Missing required keys: $($missing -join ', ')"
            }

            Log "Environment loaded and validated successfully"
            $success = $true

        } catch {
            Log "ERROR: $_"
            if ($attempt -lt $MaxRetries) {
                $delay = $InitialDelayMs * [math]::Pow(2, $attempt - 1)
                Log "Retrying in $delay ms..."
                Start-Sleep -Milliseconds $delay
            } else {
                throw "Failed to load environment after $MaxRetries attempts: $_"
            }
        }
    }

    return $envVars
}