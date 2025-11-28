# Buildmate Dependency Workflow

## 🧱 Project Overview
Buildmate is a modular Flask platform designed to streamline construction tech workflows. This project uses `pip-tools` and PowerShell automation to manage production and development dependencies with reproducibility and version control.

---

## 🖥️ Environment Setup

### Python & Virtual Environment
- Python version: **3.14**
- OS: **Windows 11**
- Create and activate virtual environment:
  ```powershell
  python -m venv venv
  .\venv\Scripts\Activate.ps1
  ```

### Install pip-tools
```powershell
pip install pip-tools
```

---

## 📦 Dependency Management

### Production Dependencies
- Defined in: `requirements/requirements.in`
- Locked with: `lock-requirements.ps1`
- Installed with: `manage-deps.ps1`

### Development Dependencies
- Defined in: `requirements/requirements-dev.in`
- Locked with: `lock-dev-requirements.ps1`
- Installed with: `manage-dev-deps.ps1`

### Full Automation
Run the bundled launcher:
```powershell
powershell -ExecutionPolicy Bypass -File "scripts/setup/launch-dependency-workflow.ps1"
```

---

## 🗂️ Folder Structure

```
buildmate/
├── requirements/
│   ├── requirements.in
│   ├── locked-requirements.txt
│   ├── requirements-dev.in
│   ├── locked-requirements-dev.txt
├── scripts/setup/
│   ├── lock-requirements.ps1
│   ├── manage-deps.ps1
│   ├── lock-dev-requirements.ps1
│   ├── manage-dev-deps.ps1
│   ├── launch-dependency-workflow.ps1
├── logs/
│   ├── deps/
│   │   ├── dev_deps_log.txt
│   ├── setup/
│   │   ├── lock-dev-log.txt
│   │   ├── bundled_launcher_log.txt
```

---

## 🔒 Version Pinning

- `pip` is pinned to `<25.3` to avoid `use_pep517` errors with `pip-tools`
- `pip-tools` is pinned to `>=7.4,<7.6` for compatibility
- All dependencies are locked using `pip-compile`

---

## 🔍 Tool Verification

After installation, verify core tools:
```powershell
black --version
flake8 --version
pytest --version
pip-compile --version
```

---

## 📝 Logging

- Logs are saved in `logs/deps/` and `logs/setup/`
- Each script appends timestamped entries for traceability

---

## 🧯 Troubleshooting

### ❌ `AttributeError: use_pep517`
- Cause: `pip-tools` incompatibility with `pip 25.3`
- Fix:
  ```powershell
  python -m pip install "pip<25.3"
  ```

### ❌ Missing lock files
- Cause: Running `pip-compile` outside virtualenv
- Fix:
  ```powershell
  .\venv\Scripts\Activate.ps1
  ```

---

## 📌 Notes

- This README is part of a 3-part documentation set:
  - `Buildmate_Reference_Manual.md`
  - `Buildmate_Technical_README.md`
  - `Buildmate_Step_by_Step_Guide.md`
- All files are stored in `buildmate/docs/` and ready for PDF export
```