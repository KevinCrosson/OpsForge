# OpsForge Markdown Lint Error Report (Sample)

This document shows what contributors will see in CI/CD logs if Markdown linting fails.  
It is intended as a training artifact for onboarding and governance enforcement.

---

## Example Output

README.md:10 MD013/line-length Line length [Expected: <= 120; Actual: 145] README.md:25 MD007/ul-indent Unordered list indentation [Expected: 2; Actual: 4] STATUS.md:5 MD041/first-line-heading First line in file should be a top-level heading ROADMAP.md:42 MD029/ol-prefix Ordered list item prefix [Expected: 1.; Actual: 3.]
Docs/COMPLIANCE.md:1 MD041/first-line-heading First line in file should be a top-level heading Docs/COMPLIANCE.md:12 MD033/no-inline-html Inline HTML [Element: <br>] LICENSE.md:8 MD013/line-length Line length [Expected: <= 100; Actual: 132] NOTICE.md:15 MD040/fenced-code-language Fenced code blocks should have a language specified

---

## Explanation of Common Errors

- **MD013 (Line length)** → Lines exceeded the configured max (120 for contributor docs, 100 for governance docs).  
- **MD007 (List indentation)** → List items indented incorrectly (expected 2 spaces).  
- **MD041 (First line heading)** → File missing a top‑level heading at the start.  
- **MD029 (Ordered list style)** → Ordered list numbering inconsistent.  
- **MD033 (Inline HTML)** → Governance doc contains inline HTML (`<br>`), which is disallowed.  
- **MD040 (Fenced code language)** → Governance doc has a code block without a language specifier.  

---

## How to Fix

1. **Line length** → Wrap text at 100–120 characters depending on doc type.  
2. **Indentation** → Use 2 spaces for lists.  
3. **Headings** → Ensure every file starts with a `# Heading`.  
4. **Ordered lists** → Use `1.`, `2.`, `3.` consistently.  
5. **Inline HTML** → Replace `<br>` or other HTML with pure Markdown.  
6. **Code blocks** → Always specify language (e.g., ` ```json `, ` ```yaml `).  

---

## Running Lint Locally

Contributors should run lint checks before committing:

```bash
# Install markdownlint-cli2 globally
npm install -g markdownlint-cli2

# Run baseline linting for contributor docs
markdownlint-cli2 "**/*.md" "#node_modules" "#.git" -c .markdownlint.json

# Run stricter linting for governance docs
markdownlint-cli2 "LICENSE.md" "NOTICE.md" "Docs/COMPLIANCE.md" -c opsforge-lint.json