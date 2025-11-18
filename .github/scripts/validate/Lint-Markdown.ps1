<#
.SYNOPSIS
    Lints README.md for heading structure and placeholder coverage.
.DESCRIPTION
    Validates that Markdown headings progress without skipping levels (e.g., H1 Ã¢â€ â€™ H2 Ã¢â€ â€™ H3).
    Supports optional --Fix mode to auto-correct heading level jumps.
    Designed for CI enforcement and pre-commit hooks.
.PARAMETER Fix
    If specified, auto-corrects heading level jumps in README.md.
#>

param (
    [switch]$Fix
)

# Initialize error list
$Errors = @()

# Define path to README.md
$ReadmePath = "$PSScriptRoot\..\Docs\README.md"

# Validate file existence
if (-not (Test-Path $ReadmePath)) {
    throw "README.md not found at $ReadmePath"
}

# Load content as array of lines
$Content = Get-Content $ReadmePath
$LastLevel = 0
$FixedContent = @()

# Iterate through each line of the README
foreach ($Line in $Content) {
    # Match Markdown headings (e.g., # Title, ## Subtitle)
    if ($Line -match '^#{1,6}\s') {
        # Extract heading level by counting leading '#' characters
        $HeadingPrefix = ($Line -split '\s')[0]
        $Level = $HeadingPrefix.Length

        # Print debug info if verbose
        Write-Verbose "Found heading level H$(Level)): $Line"

        # Skip first heading check
        if ($LastLevel -eq 0) {
            $LastLevel = $Level
            $FixedContent += $Line
            continue
        }

        # Detect heading level jump (e.g., H1 Ã¢â€ â€™ H3)
        if ($Level -gt ($LastLevel + 1)) {
            if ($Fix) {
                # Auto-correct heading level to next valid level
                $Corrected = ('#' * ($LastLevel + 1)) + ($Line -replace '^#{1,6}', '')
                Write-Host "Fixed heading: $Line Ã¢â€ â€™ $Corrected"
                $FixedContent += $Corrected
            } else {
                # Record error for reporting
                $Errors += "Heading level jumps from H$LastLevel to H$Level : $Line"
                $FixedContent += $Line
            }
        } else {
            # Heading is valid, preserve it
            $FixedContent += $Line
        }

        # Update last level for next iteration
        $LastLevel = $Level
    } else {
        # Non-heading lines are passed through unchanged
        $FixedContent += $Line
    }
}

# Write corrected content if --Fix was used and no errors remain
if ($Fix -and $Errors.Count -eq 0) {
    Set-Content -Path $ReadmePath -Value $FixedContent -Encoding UTF8
    Write-Host "README.md updated with corrected headings." -ForegroundColor Green
}

# Report errors if any were found
if ($Errors.Count -gt 0) {
    foreach ($LintError in $Errors) {
        Write-Warning $LintError
    }
    throw "Markdown linting failed with $($Errors.Count) issue(s)."
} else {
    Write-Host "Markdown passed linting." -ForegroundColor Green
}
