param (
    [switch]$DryRun,
    [switch]$Verbose
)

function Write-DevInfo {
    param ($msg)
    Write-Host "[DevTasks] $msg" -ForegroundColor Yellow
}

function Write-DevVerbose {
    param ($msg)
    if ($Verbose) {
        Write-Host "[VERBOSE] $msg" -ForegroundColor Cyan
    }
}

# --- Metadata Export ---
Log-Info "Exporting metadata and README..."
& "Scripts\Export-MetadataFiles.ps1" -DryRun:$DryRun -Verbose:$Verbose

# --- Markdown Linting ---
Log-Info "Linting markdown files..."
& "Scripts\Lint-Markdown.ps1" -Verbose:$Verbose

# --- Changelog Update ---
Log-Info "Updating CHANGELOG.md..."
& "Scripts\Update-Changelog.ps1" -DryRun:$DryRun -Verbose:$Verbose

# --- Version Tagging ---
Log-Info "Tagging version..."
& "Scripts\Tag-Version.ps1" -DryRun:$DryRun -Verbose:$Verbose

# --- Packaging Docs ---
Log-Info "Packaging documentation..."
& "Scripts\Package-Docs.ps1" -DryRun:$DryRun -Verbose:$Verbose

Log-Info "Dev task run complete."
