<#
.SYNOPSIS
    Pester tests for hygiene enforcement scripts.

.DESCRIPTION
    - Validates that Repair-CorruptedSymbols.ps1 fixes corrupted symbols and writes UTF-8 BOM.
    - Validates that Test-Environment.ps1 correctly detects BOM presence.
    - Provides CI-friendly pass/fail results.
#>

# Ensure Pester module is available
Import-Module Pester -ErrorAction Stop

$Root = (Get-Location).Path
$RepairScript = Join-Path $Root "Scripts\Maintenance\Repair-CorruptedSymbols.ps1"
$ValidateScript = Join-Path $Root "Scripts\Validate\Test-Environment.ps1"
$LogPath = Join-Path $Root "Scripts\Maintenance\Logs\SymbolFix.log"

Describe "Repair-CorruptedSymbols.ps1" {

    It "Should run in dry-run mode and log FIXABLE for dirty file" {
        # Create a temporary test file with corrupted symbols
        $TestFile = Join-Path $Root "Scripts\Tests\DirtyFile.ps1"
        Set-Content $TestFile "Write-Host "Hello World"" -Encoding UTF8

        # Run repair in dry-run mode
        & $RepairScript -Root $Root -DryRun | Out-Null

        # Assert log contains FIXABLE entry
        $LogContent = Get-Content $LogPath -Raw
        $LogContent | Should -Match "\[FIXABLE\].*DirtyFile.ps1"
    }

    It "Should fix corrupted symbols and write UTF-8 BOM" {
        $TestFile = Join-Path $Root "Scripts\Tests\DirtyFile.ps1"
        Set-Content $TestFile "Write-Host "Hello World"" -Encoding UTF8

        # Run repair live
        & $RepairScript -Root $Root | Out-Null

        # Read first 3 bytes to confirm BOM
        $Bytes = Get-Content $TestFile -Encoding Byte -TotalCount 3
        ($Bytes[0] -eq 0xEF -and $Bytes[1] -eq 0xBB -and $Bytes[2] -eq 0xBF) | Should -BeTrue

        # Confirm content was fixed
        $Content = Get-Content $TestFile -Raw
        $Content | Should -Match 'Write-Host "Hello World"'
    }
}

Describe "Test-Environment.ps1" {

    It "Should detect missing BOM in a file" {
        $TestFile = Join-Path $Root "Scripts\Tests\NoBomFile.ps1"
        # Write file without BOM
        $Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllText($TestFile, "Write-Host 'No BOM'", $Utf8NoBom)

        $Result = & $ValidateScript -Verbose
        $Result | Should -Match "Files missing UTF-8 BOM"
    }

    It "Should pass when all files have BOM" {
        $TestFile = Join-Path $Root "Scripts\Tests\BomFile.ps1"
        Set-Content $TestFile "Write-Host 'With BOM'" -Encoding UTF8BOM

        $Result = & $ValidateScript -Verbose
        $Result | Should -Match "All .ps1 files have UTF-8 BOM"
    }
}
