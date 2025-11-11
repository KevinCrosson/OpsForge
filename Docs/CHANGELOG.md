# Changelog

All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](https://semver.org/).

---

## [1.3.0] - 2025-11-10
### Added
- `tools\ReEncrypt-Env.ps1` for secure credential rotation
- `tools\Log-NetworkConnection.ps1` for manual connection logging
- `modules\FileOps\Archive-Logs.psm1` for log archiving and rotation
- Timestamp formatting via `Convert-Timestamp.psm1` in `Common\`

### Changed
- `Run-NetworkAudit.ps1` now uses modular logging and timestamp utilities
- Updated `README.md` to reflect new folder structure and usage

### Fixed
- Corrected typos in filenames (`Register-NetworkAuditTask.ps1`, `Deploy-NetworkAudit.ps1`)
- Standardized `.env.enc` loading across all orchestrators

---

## [1.2.0] - 2025-11-09
### Added
- `modules\NetworkAudit\Test-SMTP.psm1` for SMTP diagnostics
- `modules\Logging\Write-LogEntry.psm1` for standardized logging
- `modules\Auth\Load-Credentials.psm1` for secure credential handling

### Changed
- Refactored `Run-NetworkAudit.ps1` to use modular imports
- Added verbose logging to all core functions

### Fixed
- SMTP retry logic now respects exponential backoff
- Improved hostname resolution for Akamai and Azure IPs

---

## [1.1.0] - 2025-11-08
### Added
- `modules\NetworkAudit\Scan-NetworkConnections.psm1`
- `modules\NetworkAudit\Send-AlertEmail.psm1`
- `modules\NetworkAudit\Load-EnvSecure.psm1`
- `modules\NetworkAudit\Purge-OldLogs.psm1`
- `modules\NetworkAudit\Register-NetworkAuditTask.psm1`

### Changed
- Initial modularization of all core logic
- Created `NetworkAuditTask.xml` for scheduled task deployment

---

## [1.0.0] - 2025-11-07
### Added
- Initial release of `Run-NetworkAudit.ps1`
- `.env.enc` encrypted credential support
- Basic logging to `AuditLog.txt`
- Alert email dispatch via SMTP