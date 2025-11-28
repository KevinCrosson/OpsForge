# setup.ps1

Write-Host "🔧 Activating virtual environment..."
.\venv\Scripts\Activate.ps1

Write-Host "📦 Installing pip-tools..."
pip install pip-tools

Write-Host "📄 Compiling requirements..."
pip-compile backend/requirements/requirements.in --output-file backend/requirements/requirements.txt
pip-compile backend/requirements/requirements-dev.in --output-file backend/requirements/requirements-dev.txt

Write-Host "📥 Installing dev dependencies..."
pip install -r backend/requirements/requirements-dev.txt

Write-Host "✅ Setup complete."