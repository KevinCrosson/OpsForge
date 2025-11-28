<#
.SYNOPSIS
Detects confusing use of U+2019 (') near backticks (`) in source files.

.DESCRIPTION
Scans .ps1, .md, and .txt files for U+2019 and flags lines where it appears near a backtick.
Helps prevent encoding confusion and scripting errors in PowerShell and Markdown.

.EXAMPLE
.\Validate-SymbolConfusion.ps1
#>

$Root = (git rev-parse --show-toplevel)
$Files = Get-ChildItem -Path $Root -Recurse -Include *.ps1, *.md, *.txt -File

$Conflicts = @()

foreach ($File in $Files) {
    $Lines = Get-Content $File.FullName -Raw -Encoding UTF8 -ErrorAction SilentlyContinue -Force -Delimiter "`n" | Select-String "." -AllMatches
    $LineNumber = 0

    foreach ($Line in $Lines) {
        $LineNumber++
        $Text = $Line.ToString()

        if ($Text -match "[\u2019]" -and $Text -match "[`]") {
            $Conflicts += [PSCustomObject]@{
                File = $File.FullName.Replace($Root, "").TrimStart("\")
                Line = $LineNumber
                Content = $Text
            }
        }
    }
}

if ($Conflicts.Count -gt 0) {
    Write-Host "`n[FAIL] Found potential symbol confusion between U+2019 and backtick:`n"
    $Conflicts | Format-Table -AutoSize
    exit 1
} else {
    Write-Host "[PASS] No symbol confusion detected."
}
