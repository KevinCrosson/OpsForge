# ============================================
# ReEncrypt-Env.ps1
# ============================================
# Purpose:
#   - Re-encrypt the plaintext .env file using Windows DPAPI
#   - Output: .env.enc (secure, machine-bound)
#   - Used for credential rotation or initial setup
# ============================================

param (
    [Parameter(Mandatory = $true)]
    [string]$PlainEnvPath,  # Path to plaintext .env file

    [string]$EncryptedEnvPath = "$PSScriptRoot\..\env.enc"  # Output path
)

# --- Validate input file ---
if (-not (Test-Path $PlainEnvPath)) {
    Write-Error "Plaintext .env file not found at: $PlainEnvPath"
    exit 1
}

# --- Read plaintext content ---
try {
    $plainText = Get-Content $PlainEnvPath -Raw
} catch {
    Write-Error "Failed to read plaintext .env file: $_"
    exit 1
}

# --- Convert to secure byte array ---
try {
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($plainText)
    $encrypted = [System.Security.Cryptography.ProtectedData]::Protect(
        $bytes,
        $null,
        [System.Security.Cryptography.DataProtectionScope]::LocalMachine
    )
} catch {
    Write-Error "Encryption failed: $_"
    exit 1
}

# --- Write encrypted output ---
try {
    [System.IO.File]::WriteAllBytes($EncryptedEnvPath, $encrypted)
    Write-Host "Encrypted .env saved to: $EncryptedEnvPath" -ForegroundColor Green
} catch {
    Write-Error "Failed to write encrypted file: $_"
    exit 1
}