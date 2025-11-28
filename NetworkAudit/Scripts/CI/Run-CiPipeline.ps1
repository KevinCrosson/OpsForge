[CmdletBinding()]
param (
    # Optional switch to simulate actions without making changes
    [switch]$DryRun,

    # Optional switch for verbose output
    [switch]$VerboseOutput
)

Write-Host "`n🚀 Starting CI pipeline..." -ForegroundColor Cyan

# Resolve script root and paths
$ScriptRoot = $PSScriptRoot
$ValidatePath = Join-Path $ScriptRoot "..\Validate\Test-Environment.ps1"
$MetadataPath = Join-Path $ScriptRoot "..\Metadata\Generate-AllMetadata.ps1"
$ChangelogPath = Join-Path $ScriptRoot "..\Metadata\Update-Changelog.ps1"

# Run environment hygiene check
Write-Host "`n🔍 Validating environment hygiene..." -ForegroundColor Yellow
& $ValidatePath -FixBOM -VerboseOutput:$VerboseOutput
if ($LASTEXITCODE -ne 0) {
    Write-Error "❌ Environment hygiene check failed. Aborting CI pipeline."
    exit 1
}

# Run metadata generation
Write-Host "`n🧱 Generating module and folder metadata..." -ForegroundColor Yellow
& $MetadataPath -DryRun:$DryRun -Verbose:$VerboseOutput
if ($LASTEXITCODE -ne 0) {
    Write-Error "❌ Metadata generation failed. Aborting CI pipeline."
    exit 1
}

# Run changelog update
Write-Host "`n📝 Updating changelog..." -ForegroundColor Yellow
try {
    & $ChangelogPath -DryRun:$DryRun -Verbose:$VerboseOutput
} catch {
    Write-Error "Failed to update changelog: $_"
    exit 1
}

Write-Host "`n✅ CI pipeline completed successfully." -ForegroundColor Green