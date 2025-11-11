# ============================================
# Send-AlertEmail.psm1
# ============================================
# Purpose:
#   - Send alert emails using SMTP credentials
#   - Supports TLS, secure credential handling, and plain text body
# ============================================

function Send-AlertEmail {
    param (
        [string]$From,           # Sender email address
        [string]$To,             # Recipient email address
        [string]$Subject,        # Email subject line
        [string]$Body,           # Email body (plain text)
        [string]$SmtpServer,     # SMTP server address
        [int]$Port = 587,        # SMTP port (default: 587 for TLS)
        [string]$Username,       # SMTP username
        [string]$Password        # SMTP password (plaintext, securely converted below)
    )

    # --- Convert password to secure string ---
    $securePassword = ConvertTo-SecureString $Password -AsPlainText -Force

    # --- Create credential object ---
    $cred = New-Object System.Management.Automation.PSCredential($Username, $securePassword)

    # --- Attempt to send email ---
    try {
        Send-MailMessage -From $From -To $To -Subject $Subject -Body $Body `
            -SmtpServer $SmtpServer -Port $Port -UseSsl -Credential $cred

        Write-Host "Alert email sent to $To"
    } catch {
        Write-Error "Failed to send alert email: $_"
        throw $_
    }
}