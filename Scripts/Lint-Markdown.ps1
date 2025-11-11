<#
.SYNOPSIS
    Lints all Markdown files and validates README.md structure for NetworkAudit.

.DESCRIPTION
    Checks for common Markdown issues:
    - Missing H1 headings
    - Tab characters
    - Trailing whitespace
    - Missing required README sections

.NOTES
    Author: Kevin Crosson
    Usage: Run manually or integrate into pre-commit hook and release workflow
#>

param (
    [string]$RootPath = "$PSScriptRoot\..\NetworkAudit",
    [switch]$Verbose
)

# Define required README sections
$RequiredSections = @("## Installation", "## Usage", "## License")

# Collect all .md files recursively
$MarkdownFiles = Get-ChildItem -Path $RootPath -Recurse -Filter *.md

$LintErrors = @()

foreach ($File in $MarkdownFiles) {
    $Content = Get-Content $File.FullName -Raw
    $FileName = $File.Name

    # Check for H1 heading
    if ($Content -notmatch '^# ') {
        $LintErrors += "$FileName: Missing H1 heading"
    }

    # Check for tab characters
    if ($Content -match "`t") {
        $LintErrors += "$FileName: Contains tab characters"
    }

    # Check for trailing whitespace
    if ($Content -match '\s+$') {
        $LintErrors += "$FileName: Trailing whitespace detected"
    }

    if ($Verbose) {
        Write-Host "Checked: $FileName"
    }
}

# Validate README.md
$ReadmePath = Join-Path $RootPath "README.md"
if (-not (Test-Path $ReadmePath)) {
    $LintErrors += "README.md: File is missing"
} else {
    $ReadmeContent = Get-Content $ReadmePath -Raw
    foreach ($Section in $RequiredSections) {
        if ($ReadmeContent -notmatch [regex]::Escape($Section)) {
            $LintErrors += "README.md: Missing section '$Section'"
        }
    }
}

# Output results
if ($LintErrors.Count -gt 0) {
    Write-Warning "Markdown linting failed:"
    $LintErrors | ForEach-Object { Write-Warning " - $_" }
    throw "Markdown linting errors detected."
} else {
    Write-Host "Markdown linting passed." -ForegroundColor Green
}