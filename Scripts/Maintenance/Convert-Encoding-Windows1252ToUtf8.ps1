<#
.SYNOPSIS
    Recursively converts all text files in a folder from Windows-1252 to UTF-8 without BOM.

.PARAMETER Root
    Root folder to scan (defaults to current directory)

.PARAMETER Extensions
    File extensions to include (default: .ps1, .txt, .md, .json, .csv)

.PARAMETER DryRun
    If set, shows what would be converted without modifying files

.EXAMPLE
    .\Convert-Encoding-Windows1252ToUtf8.ps1 -Root "C:\.PS\NetworkAudit" -DryRun
#>

param (
    [string]$Root = ".",
    [string[]]$Extensions = @(".ps1", ".txt", ".md", ".json", ".csv"),
    [switch]$DryRun
)

$files = Get-ChildItem -Path $Root -Recurse -File | Where-Object {
    $Extensions -contains $_.Extension.ToLower()
}

if (-not $files) {
    Write-Host "No matching files found in $Root" -ForegroundColor Yellow
    return
}

foreach ($file in $files) {
    $sourcePath = $file.FullName
    $tempPath   = "$sourcePath.tmp"

    try {
        $reader = New-Object System.IO.StreamReader($sourcePath, [System.Text.Encoding]::GetEncoding(1252))
        $writer = New-Object System.IO.StreamWriter($tempPath, $false, [System.Text.UTF8Encoding]::new($false))

        while (!$reader.EndOfStream) {
            $writer.WriteLine($reader.ReadLine())
        }

        $reader.Close()
        $writer.Close()

        if ($DryRun) {
            Remove-Item $tempPath -Force
            Write-Host "[DRY-RUN] Would convert: $sourcePath" -ForegroundColor Cyan
        } else {
            Move-Item -Force -Path $tempPath -Destination $sourcePath
            Write-Host "Converted: $sourcePath" -ForegroundColor Green
        }
    }
    catch {
        Write-Warning "Failed to convert `${sourcePath}`: $_"
        if (Test-Path $tempPath) { Remove-Item $tempPath -Force }
    }
}
