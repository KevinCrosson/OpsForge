# Tools Overview

This document describes the operational scripts located in the `Tools\` folder of the NetworkAudit system. These scripts are designed for manual execution, credential management, and ad hoc logging outside the main orchestrator.

---

## Folder: `Tools\`

| Script Name                  | Description                                                                 | Usage Example |
|-----------------------------|-----------------------------------------------------------------------------|----------------|
| `ReEncrypt-Env.ps1`         | Re-encrypts the plaintext `.env` file using Windows DPAPI. Outputs `.env.enc` for secure credential loading. | `.\ReEncrypt-Env.ps1 -PlainEnvPath ".env"` |
| `Log-NetworkConnection.ps1` | Manually logs a specific IP and port to `AuditLog.txt`. Useful for testing or forensic traceability. | `.\Log-NetworkConnection.ps1 -RemoteIP "8.8.8.8" -RemotePort 443 -Hostname "Google"` |

---

## ReEncrypt-Env.ps1

### Purpose
Securely encrypts a plaintext `.env` file using Windows DPAPI (`LocalMachine` scope). This ensures credentials are protected and machine-bound.

### Parameters
- `PlainEnvPath` (required): Path to the plaintext `.env` file
- `EncryptedEnvPath` (optional): Output path for `.env.enc`

### Notes
- Output is binary and cannot be manually edited
- Used by `Load-EnvSecure.psm1` in the `NetworkAudit` module

---

## Log-NetworkConnection.ps1

### Purpose
Records a single network connection entry to `AuditLog.txt` with timestamp, trust status, and hostname.

### Parameters
- `RemoteIP` (required): IP address to log
- `RemotePort` (required): Port number
- `Hostname` (optional): Resolved or known hostname
- `Trusted` (switch): Marks connection as trusted

### Notes
- Uses `Convert-Timestamp.psm1` and `Write-LogEntry.psm1`
- Useful for manual overrides or investigation

---

## Future Additions

You may later add:
- `Test-EnvDecrypt.ps1` for validating `.env.enc` decryption
- `Rotate-Credentials.ps1` for automated credential rotation
- `DryRun-Audit.ps1` for non-logging test execution

---

## Best Practices

- Keep this folder clean: only `.ps1` scripts intended for manual or utility use
- Document each tool with usage examples and parameter notes
- Avoid placing `.md`, `.txt`, or logs in `Tools\` — use `Docs\` or root instead

---

## Maintainer

Kevin Crosson  
BuildMate Platform Architect  
Security-first automation for field operations