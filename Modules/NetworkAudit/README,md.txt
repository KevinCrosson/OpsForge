# NetworkAudit Module

## Overview
This module contains the core logic for the NetworkAudit system, including secure environment loading, network connection scanning, alert dispatch, SMTP testing, log purging, and scheduled task registration. It is designed for modular reuse, secure automation, and compliance-grade auditing.

---

## Included Components

| File                              | Purpose                                                  |
|-----------------------------------|----------------------------------------------------------|
| `Load-EnvSecure.psm1`             | Decrypts and loads `.env.enc` using Windows DPAPI        |
| `Scan-NetworkConnections.psm1`    | Scans active TCP connections and resolves hostnames      |
| `Send-AlertEmail.psm1`            | Sends alert emails via SMTP with retry logic             |
| `Test-SMTP.psm1`                  | Verifies SMTP connectivity and credentials               |
| `Register-NetworkAuditTask.psm1`  | Registers scheduled task using SYSTEM account            |
| `Purge-OldLogs.psm1`              | Deletes old logs based on retention policy               |
| `README.md`                       | Module documentation                                     |
| `VERSION.txt`                     | Current module version                                   |
| `CHANGELOG.md`                    | Module-level changelog                                   |
| `ModuleManifest.xml`              | Optional manifest for packaging or discovery             |

---

## Usage

These functions are intended to be imported into orchestrators like `Run-NetworkAudit.ps1` or CLI wrappers in `Tools\`.

### Security Notes
- All credential handling is done via Load-EnvSecure.psm1 using DPAPI encryption
- SMTP credentials and alert targets must be stored in .env.enc
- No plaintext secrets are stored or exposed


### Testing
Use Test-SMTP.psm1 to verify email dispatch before deployment:
Import-Module "$PSScriptRoot\modules\NetworkAudit\Test-SMTP.psm1"
Test-SMTP -Verbose

 Versioning
Current version:
1.3.0
See CHANGELOG.md for full history.

















