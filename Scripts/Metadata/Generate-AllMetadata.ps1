<#
.SYNOPSIS
Generates a unified metadata hashtable for the NetworkAudit project.

.DESCRIPTION
This script scans all .ps1 and .psm1 files under the Scripts and Modules directories,
extracts structured metadata from their headers, and merges it with the root-level VERSION.txt.
The resulting hashtable is returned to the caller for downstream use (e.g., README generation, changelog updates).

Supports dry-run mode and verbose logging.
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$Root,

    [switch]$DryRun,
    [switch]$Verbose
)

# Import the local metadata parser
. "$Root\Scripts\Metadata\Get-ModuleMetadata.ps1"

# Log start
Write-Host "`n[+] Generating metadata from scripts and VERSION.txt..." -ForegroundColor Cyan

# Step 1: Load version from VERSION.txt
$VersionPath = Join-Path -Path $Root -ChildPath "VERSION.txt"
if (-not (Test-Path $VersionPath)) {
    Write-Error "VERSION.txt not found at root: $VersionPath"
    return $null
}

# Extract version number using regex (e.g., 1.2.3)
$Version = Get-Content $VersionPath -Raw | Select-String -Pattern '^\s*(\d+\.\d+\.\d+)' | ForEach-Object {
    $_.Matches[0].Groups[1].Value
}

if (-not $Version) {
    Write-Error "Failed to parse version from VERSION.txt"
    return $null
}
Write-Verbose "Parsed version: $Version"

# Step 2: Recursively find all .ps1 and .psm1 files under Scripts and Modules
$ScriptDirs = @("Scripts", "Modules")
$ScriptFiles = foreach ($dir in $ScriptDirs) {
    $Path = Join-Path -Path $Root -ChildPath $dir
    if (Test-Path $Path) {
        Get-ChildItem -Path $Path -Recurse -Include *.ps1, *.psm1 -File
    }
}

if (-not $ScriptFiles) {
    Write-Warning "No script files found in Scripts or Modules."
}

# Step 3: Extract metadata from each script file using Get-ModuleMetadata
$AllModules = @()
foreach ($File in $ScriptFiles) {
    Write-Verbose "Parsing metadata from: $($File.FullName)"
    $Meta = Get-ModuleMetadata -Path $File.FullName -Verbose:$Verbose
    if ($Meta) {
        $AllModules += $Meta
    } else {
        Write-Warning "No metadata found in: $($File.FullName)"
    }
}

# Step 4: Assemble final metadata hashtable
$Metadata = @{
    Project     = "NetworkAudit"
    Version     = $Version
    Timestamp   = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    ModuleCount = $AllModules.Count
    Modules     = $AllModules
}

# Optional dry-run output
if ($DryRun) {
    Write-Host "`n[i] Dry-run output of metadata:" -ForegroundColor Yellow
    $Metadata | ConvertTo-Json -Depth 5 | Write-Output
}

# Return metadata to caller
return $Metadata
