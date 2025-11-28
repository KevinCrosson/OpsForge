# Buildmate Dependency Workflow: Step-by-Step Guide

This guide walks you through setting up and managing Buildmate’s production and development dependencies using PowerShell automation and pip-tools.

---

## 🧱 Prerequisites

- Python 3.14 installed
- Windows 11 environment
- Virtual environment created and activated
- `pip-tools` installed in the virtual environment

---

## 🪜 Step-by-Step Instructions

### ✅ Step 1: Create and Activate Virtual Environment

```powershell
python -m venv venv
.\venv\Scripts\Activate.ps1

✅ Step 2: Install pip-tools

pip install pip-tools

✅ Step 3: Prepare requirements.in

Edit requirements/requirements.in to define your production dependencies. Example:

Flask==2.3.3
Flask-SQLAlchemy==3.1.1
psycopg2-binary==2.9.11
python-dotenv==1.0.0
reportlab==4.0.8
PyPDF2==3.0.1
secure-smtplib==0.1.1

✅ Step 4: Prepare requirements-dev.in

Edit requirements/requirements-dev.in to define your dev tools. Example:

pytest
pytest-cov
black
flake8
isort
pip<25.3
pip-tools>=7.4,<7.6

✅ Step 5: Lock Production Dependencies

powershell -ExecutionPolicy Bypass -File "scripts/setup/lock-requirements.ps1"

This generates locked-requirements.txt from requirements.in.

✅ Step 6: Install Production Dependencies

powershell -ExecutionPolicy Bypass -File "scripts/setup/manage-deps.ps1"

This installs and verifies production packages.

✅ Step 7: Lock Dev Dependencies

powershell -ExecutionPolicy Bypass -File "scripts/setup/lock-dev-requirements.ps1"

This generates locked-requirements-dev.txt from requirements-dev.in.

✅ Step 8: Install Dev Dependencies

powershell -ExecutionPolicy Bypass -File "scripts/setup/manage-dev-deps.ps1"

This installs and verifies dev tools like black, flake8, and pytest.

✅ Step 9: Run Full Workflow (Optional)

To lock and install both production and dev dependencies in one step:

powershell -ExecutionPolicy Bypass -File "scripts/setup/launch-dependency-workflow.ps1"

✅ Step 10: Verify Tools

After installation, confirm that key tools are available:

black --version
flake8 --version
pytest --version
pip-compile --version

📁 Logs

Logs are saved in:

logs/setup/ (locking and full workflow)

logs/deps/ (installation and verification)

Each script appends timestamped entries for traceability

🧯 Troubleshooting

❌ AttributeError: use_pep517

Cause: pip-tools incompatibility with pip 25.3

Fix:

python -m pip install "pip<25.3"

❌ Lock file not generated

Cause: Virtual environment not activated

Fix:

.\venv\Scripts\Activate.ps1

📌 Notes

This guide is part of a 3-part documentation set:

Buildmate_Reference_Manual.md

Buildmate_Technical_README.md

Buildmate_Step_by_Step_Guide.md

All files are stored in buildmate/docs/ and ready for PDF export
