# Buildmate Dependency & Automation Reference Manual

## 🧱 Overview
Buildmate is a modular, production-grade Flask platform designed to disrupt construction tech workflows. This manual documents its dependency management strategy, PowerShell automation, and reproducibility practices for both production and development environments.

---

## 🖥️ Environment Assumptions
- Python 3.14
- Windows 11
- Virtual environment activated (`venv`)
- Folder structure rooted at `buildmate/`

---

## 📁 Folder Structure

buildmate/ ├── requirements/ │   ├── requirements.in │   ├── locked-requirements.txt │   ├── requirements-dev.in │   ├── locked-requirements-dev.txt ├── scripts/setup/ │   ├── lock-requirements.ps1 │   ├── manage-deps.ps1 │   ├── lock-dev-requirements.ps1 │   ├── manage-dev-deps.ps1 │   ├── launch-dependency-workflow.ps1 ├── logs/ │   ├── deps/ │   │   ├── dev_deps_log.txt │   ├── setup/ │   │   ├── lock-dev-log.txt │   │   ├── bundled_launcher_log.txt


---

## 📦 requirements.in

```txt
# Buildmate core dependencies

# Web framework
Flask==2.3.3
Flask-SQLAlchemy==3.1.1

# Database
psycopg2-binary==2.9.11

# Configuration
python-dotenv==1.0.0

# PDF generation and manipulation
reportlab==4.0.8
PyPDF2==3.0.1

# Email support
secure-smtplib==0.1.1

🛠️ requirements-dev.in

# Development tools for testing, formatting, and environment management

# Testing
pytest
pytest-cov

# Linting and formatting
black
flake8
isort

# Environment and packaging
pip<25.3
pip-tools>=7.4,<7.6

⚙️ PowerShell Scripts

lock-requirements.ps1
Generates locked-requirements.txt from requirements.in using pip-compile.

manage-deps.ps1
Installs production dependencies from locked-requirements.txt and verifies core packages.

lock-dev-requirements.ps1
Generates locked-requirements-dev.txt from requirements-dev.in with logging and pip-tools compatibility checks.

manage-dev-deps.ps1
Installs dev dependencies and verifies tools like black, flake8, pytest, and pip-compile.

launch-dependency-workflow.ps1
Bundled launcher that locks and installs both production and dev dependencies, with full logging and tool verification.

📝 Logging
- Logs are saved in logs/deps/ and logs/setup/
- Each script appends timestamped entries for traceability
- Log files include:
- lock-dev-log.txt
- dev_deps_log.txt
- bundled_launcher_log.txt

🔒 Version Compatibility
- pip is pinned to <25.3 to avoid use_pep517 errors with pip-tools
- pip-tools is pinned to >=7.4,<7.6 for stability
- Python 3.14 is used for future-proofing and compatibility with modern packages

🔍 Tool Verification
After install, run the following to confirm tool availability:
black --version
flake8 --version
pytest --version
pip-compile --version



🧯 Common Errors & Fixes
❌ AttributeError: use_pep517
- Cause: pip-tools incompatibility with pip 25.3
- Fix: Downgrade pip
python -m pip install "pip<25.3"


❌ Missing lock files
- Cause: Running pip-compile outside virtualenv
- Fix: Activate venv before locking
.\venv\Scripts\Activate.ps1



🧠 Maintenance Tips
- Regenerate lock files after updating .in files
- Keep logs clean by rotating or archiving periodically
- Use launch-dependency-workflow.ps1 for full automation
- Pin versions explicitly to avoid future breakage

📌 Notes
- This manual is part of a 3-part documentation set:
- Buildmate_Reference_Manual.md
- Buildmate_Technical_README.md
- Buildmate_Step_by_Step_Guide.md
- All files are stored in buildmate/docs/ and ready for PDF export
