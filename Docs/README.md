## NetworkAudit System

## Overview
NetworkAudit -  <!-- --> if you want to test without losing it
is a modular PowerShell-based system for secure, automated network auditing in Windows environments. It scans active TCP connections, flags untrusted IPs, logs results, and sends alert emails using encrypted credentials. It also supports scheduled task registration, log retention enforcement, and secure credential management.

This system is designed for compliance-driven IT operations, proactive monitoring, and scalable deployment.

---

## Features
- Secure environment loading from `.env.enc` using DPAPI
- Structured TCP connection scanning with hostname resolution
- Trusted domain filtering (Microsoft, Akamai, Azure, etc.)
- Alert email dispatch via SMTP with retry logic
- Log retention enforcement with purge module
- Scheduled task registration using SYSTEM account
- SMTP test harness with exponential backoff and logging
- Re-encryption of environment files for credential rotation
- Modular architecture with reusable components

---

## Usage
```powershell
.\Run-NetworkAudit.ps1

### Deploy Scheduled Task + Purge
.\Deploy-NetworkAudit.ps1

### Purge Old Logs Manually
.\Purge-OldLogs.ps1

### Re-encrypt Environment File
.\tools\ReEncrypt-Env.ps1

### Log a Single Connection (Manual)
.\tools\Log-NetworkConnection.ps1 -RemoteIP "1.2.3.4" -RemotePort 443

## Dependencies
- PowerShell 5.1+
- Windows Task Scheduler
- SMTP access for alerting
- Required Modules:
- modules\NetworkAudit\*.psm1
- modules\Auth\Load-Credentials.psm1
- modules\Common\Convert-Timestamp.psm1
- modules\FileOps\Archive-Logs.psm1
- modules\Logging\Write-LogEntry.psm1

## File Structure
NetworkAudit\
├── Run-NetworkAudit.ps1
├── Deploy-NetworkAudit.ps1
├── Register-NetworkAuditTask.ps1
├── Purge-OldLogs.ps1
├── .env.enc
├── AuditLog.txt
├── PurgeLog.txt
├── SMTPTest.log
├── README.md
├── VERSION.txt
├── CHANGELOG.md
├── LICENSE
├── NetworkAuditTask.xml
├── tools\
│   ├── Log-NetworkConnection.ps1
│   └── ReEncrypt-Env.ps1
└── modules\
    ├── NetworkAudit\
    │   ├── Load-EnvSecure.psm1
    │   ├── Scan-NetworkConnections.psm1
    │   ├── Send-AlertEmail.psm1
    │   ├── Test-SMTP.psm1
    │   ├── Register-NetworkAuditTask.psm1
    │   ├── Purge-OldLogs.psm1
    │   ├── README.md
    │   ├── VERSION.txt
    │   ├── CHANGELOG.md
    │   └── ModuleManifest.xml
    ├── Auth\
    │   └── Load-Credentials.psm1
    ├── Common\
    │   └── Convert-Timestamp.psm1
    ├── FileOps\
    │   └── Archive-Logs.psm1
    └── Logging\
        └── Write-LogEntry.psm1

## Authors
Kevin Crosson
Senior IT Support Specialist & Systems Architect
BuildMate Platform — Secure, Modular FieldOps Automation

## License
This project is licensed under the MIT License.
See LICENSE for full terms.
