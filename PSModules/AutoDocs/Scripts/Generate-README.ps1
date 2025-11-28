<#
.SYNOPSIS
    Generates README.md from a template in Docs.

.DESCRIPTION
    - Reads Docs\README.template.md
    - Replaces placeholders (e.g., {{Version}})
    - Writes final README.md at repo root
#>

$Root        = (Get-Location).Path
$TemplatePath = Join-Path $Root "Docs\README.template.md"
$OutputPath   = Join-Path $Root "README.md"
$VersionPath  = Join-Path $Root "Docs\VERSION"

# Ensure template exists
if (-not (Test-Path $TemplatePath)) {
    Write-Error "README template not found at $TemplatePath"
    exit 1
}

# Read template and version
$template = Get-Content $TemplatePath -Raw
$version  = (Get-Content $VersionPath -Raw).Trim()

# Replace placeholders
$content = $template -replace "{{Version}}", $version

# Write README.md
Set-Content -Path $OutputPath -Value $content -Encoding UTF8
Write-Output "✅ README.md generated successfully."
