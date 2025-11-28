# OpsForge Release Strategy

OpsForge manages multiple projects under one umbrella: **NetworkAudit**, **BuildMate**, and shared modules like **AutoDocs**.  
This document defines how releases are tagged, bundled, and published.

---

## 🔖 Tagging Conventions
- **OpsForge (umbrella)** → `opsforge-vX.Y.Z`
- **NetworkAudit** → `networkaudit-vX.Y.Z`
- **BuildMate** → `buildmate-vX.Y.Z`
- **AutoDocs** → `autodocs-vX.Y.Z`

---

## 🚀 Release Workflow
1. Run local bundling/tests:
   - `Invoke-BundleDocs` for AutoDocs
   - `pwsh NetworkAudit/Scripts/Dispatchers/Bundle-Docs.ps1`
   - `Invoke-Pester BuildMate/Tests`
2. Commit changes and bump version.
3. Tag with the correct prefix.
4. Push → GitHub Actions detects tag and publishes release.

---

## 📦 Release Artifacts
- **OpsForge** → ecosystem docs, workflows, shared modules.
- **NetworkAudit** → dashboards, scripts, changelog.
- **BuildMate** → drone configs, metadata tooling.
- **AutoDocs** → module manifest, usage examples.

---

## 👥 Contributor Notes
- Always run tests before tagging.
- Use semantic versioning (major.minor.patch).
- CI/CD will enforce hygiene and attach artifacts automatically.
