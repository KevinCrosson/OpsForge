<#
.SYNOPSIS
Automatically moves known utility scripts to their designated folders within the NetworkAudit project.

.DESCRIPTION
This script scans the current directory (or a specified source) for known utility scripts and moves them to their correct destinations based on predefined mappings. It supports dry-run mode, verbose logging, and error handling to ensure safe execution.

.PARAMETER Source
Optional path to scan for utility scripts. Defaults to the current directory.

.PARAMETER DryRun
If specified, performs a simulation without moving any files.

.EXAMPLE
.\Auto-Move-UtilityScripts.ps1 -Source "DevRunner/Scripts" -DryRun
#>

param (
    [string]$Source = ".",
    [switch]$DryRun
)

# Define the mapping of script names to their target folders
$ScriptMap = @{
    "Detect-BrokenImports.ps1"     = "Scripts/Validate"
    "Fix-BrokenImports.ps1"        = "Scripts/Cleanup"
    "Update-ImportPaths.ps1"       = "Scripts/Cleanup"
    "Generate-FolderDiagram.ps1"   = "Tools"
    "Lint-TemplatePlaceholders.ps1"= "Scripts/Docs"
    "Run-CiPipeline.ps1"           = "Scripts/CI"
    "Run-DevTasks.ps1"             = "Scripts/Dispatchers"
}

# Resolve full path of source directory
$ResolvedSource = Resolve-Path -Path $Source

# Track results for summary
$MovedScripts = @()
$SkippedScripts = @()
$Errors = @()

Write-Host "`n[INFO] Scanning source directory: $ResolvedSource`n"

foreach ($ScriptName in $ScriptMap.Keys) {
    $TargetFolder = $ScriptMap[$ScriptName]
    $SourcePath = Join-Path -Path $ResolvedSource -ChildPath $ScriptName
    $TargetPath = Join-Path -Path $TargetFolder -ChildPath $ScriptName

    if (Test-Path $SourcePath) {
        Write-Host "[FOUND] $ScriptName in source directory."

        if ($DryRun) {
            Write-Host "[DRY-RUN] Would move '$ScriptName' to '$TargetFolder'"
            $SkippedScripts += $ScriptName
        }
        else {
            try {
                # Ensure target folder exists
                if (-not (Test-Path $TargetFolder)) {
                    Write-Host "[CREATE] Target folder '$TargetFolder' does not exist. Creating..."
                    New-Item -ItemType Directory -Path $TargetFolder -Force | Out-Null
                }

                # Move the file
                Move-Item -Path $SourcePath -Destination $TargetPath -Force
                Write-Host "[MOVED] '$ScriptName' moved to '$TargetFolder'"
                $MovedScripts += $ScriptName
            }
            catch {
                Write-Warning "[ERROR] Failed to move '$ScriptName': $_"
                $Errors += $ScriptName
            }
        }
    }
    else {
        Write-Host "[SKIP] '$ScriptName' not found in source directory."
        $SkippedScripts += $ScriptName
    }
}

# Summary
Write-Host "`n[SUMMARY]"
Write-Host "Moved Scripts   : $($MovedScripts.Count)"
Write-Host "Skipped Scripts : $($SkippedScripts.Count)"
Write-Host "Errors          : $($Errors.Count)"

if ($DryRun) {
    Write-Host "`n[NOTE] Dry-run mode was enabled. No files were moved."
}
