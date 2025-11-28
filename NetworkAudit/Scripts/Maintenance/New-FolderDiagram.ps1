<#
.SYNOPSIS
    Creates a visual folder diagram and validates its freshness.

.DESCRIPTION
    Scans the folder structure of the NetworkAudit repository, writes it to Docs\FolderStructure.png,
    and updates a freshness badge. Warns if the diagram is stale.

.NOTES
    Author: Kevin Crosson
    Last Updated: 2025-11-19
    CI Status: PSScriptAnalyzer-compliant
#>

param (
    [switch]$Verbose,   # Enables detailed output
    [switch]$DryRun     # Prevents file writes (safe for CI testing)
)

# Resolve root path safely whether run as script or interactively
$Root = if ($MyInvocation.MyCommand.Path) {
    Split-Path -Parent $MyInvocation.MyCommand.Path
} else {
    Get-Location
}

# Define output paths
$DocsPath     = Join-Path $Root "Docs"
$DiagramPath  = Join-Path $DocsPath "FolderStructure.png"
$BadgePath    = Join-Path $DocsPath "FolderDiagramBadge.txt"

# Ensure Docs folder exists
if (-not (Test-Path $DocsPath)) {
    New-Item -Path $DocsPath -ItemType Directory | Out-Null
    if ($Verbose) {
        Write-Host "📁 Created Docs folder at $DocsPath" -ForegroundColor Cyan
    }
}

function Get-FolderStructure {
    <#
    .SYNOPSIS
        Recursively collects folder paths, excluding common noise.
    #>
    Get-ChildItem -Path $Root -Directory -Recurse |
        Where-Object { $_.FullName -notmatch '\\(\.git|node_modules|venv|__pycache__)' } |
        Select-Object -ExpandProperty FullName
}

function New-FolderDiagram {
    <#
    .SYNOPSIS
        Writes folder structure to FolderStructure.png
    #>
    $Structure = Get-FolderStructure
    $DiagramContent = $Structure -join "`n"

    if ($Verbose) {
        Write-Host "📁 Folder structure contains $($Structure.Count) directories" -ForegroundColor Cyan
    }

    if (-not $DryRun) {
        $DiagramContent | Set-Content -Path $DiagramPath -Encoding UTF8
        if ($Verbose) {
            Write-Host "✅ Diagram written to $DiagramPath" -ForegroundColor Green
        }
    } else {
        Write-Host "🧪 Dry run: diagram not written" -ForegroundColor Yellow
    }
}

function Test-FolderDiagramFreshness {
    <#
    .SYNOPSIS
        Validates diagram freshness and updates badge.
    #>
    if (-not (Test-Path $DiagramPath)) {
        Write-Error "⚠ FolderStructure.png not found. Please generate it."
        return
    }

    $lastModified = (Get-Item $DiagramPath).LastWriteTime
    $ageDays = [math]::Floor(((Get-Date) - $lastModified).TotalDays)

    if ($Verbose) {
        Write-Host "📁 FolderStructure.png last modified: $lastModified ($ageDays days ago)" -ForegroundColor Yellow
    }

    if ($ageDays -gt 7) {
        Write-Error "⚠ Diagram is stale: $ageDays days old. Please regenerate it."
    } else {
        Write-Host "✅ Diagram is fresh and valid." -ForegroundColor Green
    }

    if (-not $DryRun) {
        "Last updated: $lastModified ($ageDays days ago)" | Set-Content -Path $BadgePath -Encoding UTF8
        Write-Host "✅ Freshness badge updated at $BadgePath" -ForegroundColor Green
    }
}

# Execute main logic
New-FolderDiagram
Test-FolderDiagramFreshness