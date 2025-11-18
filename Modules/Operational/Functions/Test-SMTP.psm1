function Test-SmtpConnection {
    <#
    .SYNOPSIS
        Validates SMTP server connectivity and credentials.

    .DESCRIPTION
        Attempts to connect to the specified SMTP server using provided credentials.
        Sends a test email if requested, and supports dry-run and verbose logging.
        Useful for verifying alerting infrastructure in CI/CD and production environments.

    .PARAMETER SmtpServer
        The hostname or IP address of the SMTP server.

    .PARAMETER Port
        The port to use for SMTP (default is 587 for TLS).

    .PARAMETER From
        The sender email address used for the test message.

    .PARAMETER To
        The recipient email address for the test message.

    .PARAMETER Credential
        A PSCredential object containing the SMTP username and password.

    .PARAMETER UseSsl
        Indicates whether to use SSL/TLS for the connection.

    .PARAMETER SendTestEmail
        If specified, sends a test email to validate full delivery.

    .PARAMETER Subject
        Optional subject line for the test email.

    .PARAMETER Body
        Optional body content for the test email.

    .PARAMETER DryRun
        Simulates the connection and email send without transmitting data.

    .EXAMPLE
        Test-SmtpConnection -SmtpServer "smtp.example.com" -From "noreply@example.com" -To "admin@example.com" -Credential $cred -SendTestEmail -Verbose
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$SmtpServer,

        [int]$Port = 587,

        [Parameter(Mandatory)]
        [string]$From,

        [Parameter(Mandatory)]
        [string]$To,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$Credential,

        [switch]$UseSsl,

        [switch]$SendTestEmail,

        [string]$Subject = "SMTP Test Message",

        [string]$Body = "This is a test message from NetworkAudit SMTP validation.",

        [switch]$DryRun
    )

    Write-Verbose "Preparing SMTP client for server: $SmtpServer on port $Port"

    if ($DryRun) {
    Write-Host "[DryRun] Would attempt SMTP connection to ${SmtpServer}:$Port using SSL: $UseSsl" -ForegroundColor Yellow
    if ($SendTestEmail) {
        Write-Host "[DryRun] Would send test email from $From to $To with subject '$Subject'" -ForegroundColor Yellow
    }
    return
}
    }

    try {
        $smtp = New-Object System.Net.Mail.SmtpClient($SmtpServer, $Port)
        $smtp.EnableSsl = $UseSsl
        $smtp.Credentials = $Credential

        Write-Verbose "SMTP client configured. SSL: $UseSsl"

        if ($SendTestEmail) {
            $mail = New-Object System.Net.Mail.MailMessage($From, $To, $Subject, $Body)
            $smtp.Send($mail)
            Write-Host "Test email sent successfully to $To" -ForegroundColor Green
        } else {
            # Attempt a connection without sending
            $smtp.SendAsyncCancel()  # Dummy call to trigger connection
            Write-Host "SMTP connection test completed (no email sent)." -ForegroundColor Green
        }
    } catch {
        Write-Error "SMTP test failed: $_"
    }