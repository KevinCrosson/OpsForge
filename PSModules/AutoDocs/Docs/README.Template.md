# NetworkAudit / AutoDocs

> Automated documentation bundler and hygiene enforcement tool for reproducible releases.

---

## 📦 Version
Current release: **{{Version}}**

Generated on: **{{Date}}**

---

## 📝 Overview
AutoDocs is a standalone PowerShell tool that:
- Generates `README.md` from this template
- Updates `CHANGELOG.md` with the latest version entry
- Bumps the version in `Docs\VERSION`
- Copies `LICENSE` into the Docs folder
- Validates documentation hygiene with CI/CD integration

---

## 🚀 Quick Start

### Local Usage
Run the dispatcher to bundle docs:
```powershell
pwsh Scripts\Dispatchers\Bundle-Docs.ps1


## 📖 Usage Examples

{{UsageExamples}}

