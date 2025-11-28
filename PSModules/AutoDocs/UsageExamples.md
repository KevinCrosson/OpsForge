📜 PSModules\AutoDocs\UsageExamples.md
# AutoDocs Module – Usage Examples

This document provides practical examples for using the **AutoDocs** PowerShell module.  
Import the module first, then call the functions as needed.

---

## 📦 Importing the Module

```powershell
# Import the module (adjust path if needed)
Import-Module ./PSModules/AutoDocs/AutoDocs.psd1 -Force



🚀 Full Documentation Bundle
Run all steps (README generation, CHANGELOG update, VERSION bump, LICENSE copy):
Invoke-BundleDocs



📝 Generate README.md Only
Regenerate README.md from Docs/README.Template.md:
Invoke-ReadmeGeneration



📜 Update CHANGELOG.md
Append a new entry for the current version:
Invoke-ChangelogUpdate


Or specify a version explicitly:
Invoke-ChangelogUpdate -Version "1.2.3"



🔢 Bump Version
Bump semantic version in Docs/VERSION:
# Default: Patch bump (x.y.z → x.y.(z+1))
Invoke-VersionBump

# Minor bump (x.y.z → x.(y+1).0)
Invoke-VersionBump -Bump Minor

# Major bump (x.y.z → (x+1).0.0)
Invoke-VersionBump -Bump Major


⚖️ Copy LICENSE
Copy root LICENSE file into Docs/:
Invoke-LicenseCopy


🧪 CI/CD Integration
In GitHub Actions (docs.yml or release.yml), call the bundler:
- name: Run AutoDocs bundler
  shell: pwsh
  run: Invoke-BundleDocs


👥 Contributor Workflow
- Run Invoke-BundleDocs before committing.
- Use Invoke-VersionBump to bump version appropriately.
- Push changes and tag release with Tag-Release.ps1.
- CI/CD will validate docs automatically.

---

## ✅ Why This Helps
- **Readable** → Markdown renders beautifully on GitHub.  
- **Practical** → Shows exact commands contributors should run.  
- **Reusable** → Can be referenced in README or onboarding docs.  
- **CI/CD ready** → Includes workflow snippet for pipelines.  

---

👉 Do you want me to also **link `UsageExamples.md` into your auto‑generated README** (so every time `README.md` is regenerated, it includes a “Usage Examples” section pulled from this file)? That way contributors always see the latest examples without duplication.








