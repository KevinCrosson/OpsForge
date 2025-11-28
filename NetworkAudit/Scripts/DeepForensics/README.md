# DeepForensics DVR Parser

## Overview
`Parse-DVRLogs.ps1` is the master parser for DVR/NVR logs.  
It handles:
- HDD S.M.A.R.T. health anomalies
- Video tampering alarms
- System recording status
- SHA-256 hash generation for chain-of-custody

This script folds in the tamper-event parsing logic (previously `Parse-DVRTamperEvents.ps1`) so everything is unified in one tool.

---

## Usage
Run the parser against a DVR/NVR log file:

```powershell
.\Parse-DVRLogs.ps1 -LogPath "Tests\SampleLogs.txt"
```

---

## Output
The script produces two artifacts in the same folder as the input log:

- `DVR_Audit.json` → structured forensic results
- `DVR_Audit.hash` → SHA-256 fingerprint of the JSON file

---

## Verification
To verify integrity of the JSON against the hash:

```powershell
Get-FileHash -Path DVR_Audit.json -Algorithm SHA256
```

Compare the computed hash against the contents of `DVR_Audit.hash`.  
If they match, the artifact is unaltered and chain-of-custody is intact.

---

## Example
See the sample outputs in `Docs/`:

- `Docs/DVR_Audit_Sample.json` → Example structured forensic results
- `Docs/DVR_Audit_Sample.hash` → Example SHA-256 hash

These examples show how anomalies, tamper events, and system status are represented in JSON.

---

## Repository Structure
```
DeepForensics/
├── Parse-DVRLogs.ps1          # Master parser (SMART + Tamper + System Status + Hashing)
├── README.md                  # Contributor onboarding + usage instructions
├── Docs/
│   ├── DVR_Audit_Sample.json  # Example JSON output
│   └── DVR_Audit_Sample.hash  # Example SHA-256 hash
└── Tests/
    └── SampleLogs.txt         # Example DVR/NVR log input for testing
```

---

## Contributor Notes
- Always commit both `DVR_Audit.json` and `DVR_Audit.hash` together to preserve audit integrity.
- Use `Tests/SampleLogs.txt` to validate parser changes before merging.
- Extend parsing logic carefully to maintain chain-of-custody standards.