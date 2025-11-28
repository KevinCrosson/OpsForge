# Send email securely using SMTP
import smtplib, os
from email.message import EmailMessage

def send_email(subject, body, to_email):
    msg = EmailMessage()               # Create email object
    msg.set_content(body)              # Set body
    msg['Subject'] = subject           # Set subject
    msg['From'] = os.getenv("SMTP_USER")  # Sender
    msg['To'] = to_email               # Recipient

    # Send email via Gmail SMTP
    with smtplib.SMTP_SSL('smtp.gmail.com', 465) as smtp:
        smtp.login(os.getenv("SMTP_USER"), os.getenv("SMTP_PASS"))
        smtp.send_message(msg)