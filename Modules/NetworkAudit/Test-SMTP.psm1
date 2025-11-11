# ============================================
# Test-SMTP.psm1
# ============================================
# Purpose:
#   - Send a test email using SMTP credentials
#   - Retry on failure with exponential backoff
#   - Log results to a file
# ============================================

function Test-SMTPConnection {
    param (
        [hashtable]$EnvVars,                      # Loaded environment variables
        [int]$MaxRetries = 3,                     # Number of retry attempts
        [int]$InitialDelayMs = 500,               # Initial delay before retry (ms)
        [string]$LogPath = "C:\.PS\Logs\NetworkAudit\SMTPTest.log"  # Log file path
    )

    $attempt = 0
    $success = $false

    # --- Logging helper ---
    function Log {
        param ([string]$msg)
        $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        Add-Content -Path $LogPath -Value "$timestamp - $msg"
    }

    # --- Extract SMTP credentials and email fields ---
    $smtpServer = $EnvVars["SMTP_SERVER"]
    $smtpPort   = $EnvVars["SMTP_PORT"]
    $emailFrom  = $EnvVars["EMAIL_FROM"]
    $emailTo    = $EnvVars["EMAIL_TO"]
    $subject    = "$($EnvVars["EMAIL_SUBJECT"]) — SMTP Test"
    $username   = $EnvVars["EMAIL_USERNAME"]
    $password   = $EnvVars["EMAIL_PASSWORD"]

    # --- Compose email body ---
    $body = @"
This is a test message from Test-SMTPConnection.

SMTP credentials and TLS connectivity were successfully verified.

Timestamp: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
"@

    # --- Convert password to secure string and create credential object ---
    $securePassword = ConvertTo-SecureString $password -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential($username, $securePassword)

    # --- Retry loop with exponential backoff ---
    while (-not $success -and $attempt -lt $MaxRetries) {
        try {
            $attempt++
            Log "Attempt $attempt: Sending test email to $emailTo"

            Send-MailMessage -From $emailFrom -To $emailTo -Subject $subject -Body $body `
                -SmtpServer $smtpServer -Port $smtpPort -UseSsl -Credential $cred

            Log "Test email sent successfully"
            $success = $true
        } catch {
            Log "ERROR: $_"
            if ($attempt -lt $MaxRetries) {
                $delay = $InitialDelayMs * [math]::Pow(2, $attempt - 1)
                Log "Retrying in $delay ms..."
                Start-Sleep -Milliseconds $delay
            } else {
                Log "Failed after $MaxRetries attempts"
                throw "SMTP test failed: $_"
            }
        }
    }
}