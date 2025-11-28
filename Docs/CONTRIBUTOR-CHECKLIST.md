# OpsForge Contributor Checklist

This checklist is a quick reference for contributors.  
Run through these steps before committing or opening a Pull Request.

---

## ✅ Pre-Commit Checklist

- [ ] **Run lint checks locally**
  ```bash
  npm install -g markdownlint-cli2
  markdownlint-cli2 "**/*.md" "#node_modules" "#.git" -c .markdownlint.json
  markdownlint-cli2 "LICENSE.md" "NOTICE.md" "Docs/COMPLIANCE.md" -c opsforge-lint.json

- [ ] Fix all lint errors
- Wrap text at 100–120 characters depending on doc type.
- Use 2 spaces for list indentation.
- Ensure every file starts with a # Heading.
- Use 1., 2., 3. consistently for ordered lists.
- Remove inline HTML (<br>, <div>, etc.).
- Add language specifiers to fenced code blocks (```json, ```yaml).
- [ ] Check governance docs
- LICENSE.md, NOTICE.md, and Docs/COMPLIANCE.md must follow stricter rules.
- No inline HTML, mandatory top-level heading, fenced code blocks must specify language.
- [ ] Confirm CI/CD passes locally
- Run scripts in Scripts/Metadata/ if modified.
- Validate Docs/status.json using:

python Scripts/Metadata/validate_status_json.py

• 	[ ] Commit with clear message

git commit -m "Fix lint issues and update documentation"

## 📖 Resources

- [Looks like the result wasn't safe to show. Let's switch things up and try something else!] → Sample lint errors and fixes.

- [Looks like the result wasn't safe to show. Let's switch things up and try something else!] → Full onboarding guide.

- [Looks like the result wasn't safe to show. Let's switch things up and try something else!] → Current project progress.

- [Looks like the result wasn't safe to show. Let's switch things up and try something else!] → Future milestones.

## 🚀 Final Reminder

CI/CD will block merges if lint errors remain.
Run checks, fix issues, and keep OpsForge documentation clean and consistent!

---

## 📍 Placement

- Place this file in the **`Docs/` folder**.  
- It complements `CONTRIBUTING.md` (root) by serving as a **quick reference card**.  
- Example layout:

OpsForge/ ├── CONTRIBUTING.md ├── Docs/ │   ├── LINT-ERROR-REPORT.md │   ├── CONTRIBUTOR-CHECKLIST.md   <-- quick reference card │   └── COMPLIANCE.md

