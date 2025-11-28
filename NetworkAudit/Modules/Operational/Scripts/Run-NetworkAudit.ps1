<#
.SYNOPSIS
Master orchestrator for the NetworkAudit system.

.DESCRIPTION
Runs all core modules in sequence:
- Metadata generation and markdown export
- Version sync and changelog update
- Markdown linting
- Folder structure validation
- ARP and traffic monitoring
- Optional CI hooks and packaging

Supports dry-run and verbose modes for safe testing and diagnostics.

.PARAMETER DryRun
Simulates execution without writing logs or modifying files.

.PARAMETER Verbose
Enables detailed console output for each step.

.NOTES
Author: Kevin Crosson
Date: 2025-11-13
#>

param (
    [switch]$DryRun,
    [switch]$Verbose
)

function Write-InfoLog {
    param (
        [string]$Message
    )
    Write-Host "[INFO] $Message" -ForegroundColor Green
}

function Write-VerboseLog {
    if ($Verbose) {
        Write-Host "[VERBOSE] $args" -ForegroundColor Cyan
    }

}
# --- Step 1: Metadata Generation ---
Log-Info "Generating metadata and exporting documentation..."
$MetadataScript = "Scripts\Export-MetadataFiles.ps1"
if (Test-Path $MetadataScript) {
    & $MetadataScript -DryRun:$DryRun -Verbose:$Verbose
} else {
    Write-Warning "Metadata script not found at $MetadataScript"
}

# --- Step 2: Markdown Linting ---
Log-Info "Linting markdown files..."
$LintScript = "Scripts\Lint-Markdown.ps1"
if (Test-Path $LintScript) {
    & $LintScript -Verbose:$Verbose
} else {
    Write-Warning "Lint script not found at $LintScript"
}

# --- Step 3: Folder Structure Validation ---
Log-Info "Validating folder structure..."
$ValidateScript = "Scripts\Validate-FolderStructure.ps1"
if (Test-Path $ValidateScript) {
    & $ValidateScript -Verbose:$Verbose
} else {
    Write-Warning "Validation script not found at $ValidateScript"
}

# --- Step 4: ARP and Traffic Monitoring ---
Log-Info "Running ARP and traffic monitor..."
$MonitorScript = "Scripts\Monitor-ArpAndTraffic.ps1"
if (Test-Path $MonitorScript) {
    & $MonitorScript -DryRun:$DryRun -Verbose:$Verbose
} else {
    Write-Warning "Monitor script not found at $MonitorScript"
}

# --- Step 5: Version Tagging (Optional) ---
Log-Info "Tagging version (if applicable)..."
$TagScript = "Scripts\Tag-Version.ps1"
if (Test-Path $TagScript) {
    & $TagScript -DryRun:$DryRun -Verbose:$Verbose
} else {
    Write-Warning "Version tagging script not found at $TagScript"
}

# --- Step 6: Packaging (Optional) ---
Log-Info "Packaging documentation and release artifacts..."
$PackageScript = "Scripts\Package-Docs.ps1"
if (Test-Path $PackageScript) {
    & $PackageScript -DryRun:$DryRun -Verbose:$Verbose
} else {
    Write-Warning "Packaging script not found at $PackageScript"
}

# --- Final Summary ---
Log-Info "NetworkAudit run complete."
if ($DryRun) {
    Write-Host "Dry-run mode: no files were modified." -ForegroundColor Gray
}
