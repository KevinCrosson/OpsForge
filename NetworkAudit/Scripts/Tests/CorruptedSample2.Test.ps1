<#
.SYNOPSIS
Pester test suite for CorruptedSample2.ps1 repair validation.

.DESCRIPTION
Runs Repair-CorruptedSymbols.ps1 against the deliberately corrupted test file
and asserts that BOM, curly quotes, and ellipses are detected and replaced.
#>

Import-Module Pester -ErrorAction Stop

$RepairScript = "$PSScriptRoot\..\Maintenance\Repair-CorruptedSymbols.ps1"
$TestFile     = "$PSScriptRoot\CorruptedSample2.ps1"
$LogPath      = "$PSScriptRoot\..\Maintenance\Logs\SymbolFix.log"

Describe "Repair-CorruptedSymbols.ps1 on CorruptedSample2.ps1" {

    Context "Dry-run detection" {
        It "Should log replacements for BOM, curly quotes, and ellipsis" {
            # Run repair in dry-run mode
            & $RepairScript -Root $PSScriptRoot -DryRun -Verbose

            # Read log
            $log = Get-Content $LogPath -Raw

            # Assertions
            $log | Should -Match "U\+FEFF"
            $log | Should -Match "U\+201C"
            $log | Should -Match "U\+201D"
            $log | Should -Match "U\+2026"
        }
    }

    Context "Live repair" {
        It "Should replace corrupted symbols with ASCII equivalents" {
            # Run repair live
            & $RepairScript -Root $PSScriptRoot -Verbose

            # Read file after repair
            $content = Get-Content $TestFile -Raw -Encoding UTF8

            # Assertions
            $content | Should -Not -Match """
            $content | Should -Not -Match """
            $content | Should -Not -Match "..."
            $content | Should -Not -Match "`uFEFF"

            # Confirm replacements
            $content | Should -Match '"CurlyQuotesTest...Here"'
        }
    }
}
# ------------------------------------------------------------
# CorruptedSample2.Test.ps1
# ------------------------------------------------------------
# PURPOSE:
#   Validates that Repair-CorruptedSymbols.ps1 detects and fixes
#   all corrupted symbols in CorruptedSample2.ps1.
#
# STRUCTURE:
#   - Dry-run detection: ensures log contains entries for all symbols
#   - Live repair: ensures Unicode symbols are gone and ASCII equivalents exist
# ------------------------------------------------------------

Import-Module Pester -ErrorAction Stop

# Paths
$RepairScript = "$PSScriptRoot\..\Maintenance\Repair-CorruptedSymbols.ps1"
$TestFile     = "$PSScriptRoot\CorruptedSample2.ps1"
$LogPath      = "$PSScriptRoot\..\Maintenance\Logs\SymbolFix.log"

Describe "Repair-CorruptedSymbols.ps1 on CorruptedSample2.ps1" {

    Context "Dry-run detection" {
        It "Should log replacements for all corrupted symbols" {
            # Run repair in dry-run mode
            & $RepairScript -Root $PSScriptRoot -DryRun -Verbose

            # Read log
            $log = Get-Content $LogPath -Raw

            # Assertions: check log contains entries for each symbol
            $log | Should -Match "U\+FEFF"
            $log | Should -Match "U\+201C"
            $log | Should -Match "U\+201D"
            $log | Should -Match "U\+2018"
            $log | Should -Match "U\+2019"
            $log | Should -Match "U\+2013"
            $log | Should -Match "U\+2014"
            $log | Should -Match "U\+2026"
            $log | Should -Match "U\+2022"
            $log | Should -Match "U\+00A0"
            $log | Should -Match "U\+202F"
            $log | Should -Match "U\+2039"
            $log | Should -Match "U\+203A"
            $log | Should -Match "U\+00AB"
            $log | Should -Match "U\+00BB"
            $log | Should -Match "U\+2192"
            $log | Should -Match "U\+2190"
            $log | Should -Match "U\+21D2"
            $log | Should -Match "U\+21D0"
            $log | Should -Match "U\+00B0"
            $log | Should -Match "U\+00A9"
            $log | Should -Match "U\+00AE"
            $log | Should -Match "U\+2122"
            $log | Should -Match "U\+200B"
        }
    }

    Context "Live repair" {
        It "Should replace corrupted symbols with ASCII equivalents" {
            # Run repair live
            & $RepairScript -Root $PSScriptRoot -Verbose

            # Read file after repair
            $content = Get-Content $TestFile -Raw -Encoding UTF8

            # Assert Unicode symbols are gone
            $content | Should -Not -Match "`uFEFF"
            $content | Should -Not -Match "`u201C"
            $content | Should -Not -Match "`u201D"
            $content | Should -Not -Match "`u2018"
            $content | Should -Not -Match "`u2019"
            $content | Should -Not -Match "`u2013"
            $content | Should -Not -Match "`u2014"
            $content | Should -Not -Match "`u2026"
            $content | Should -Not -Match "`u2022"
            $content | Should -Not -Match "`u00A0"
            $content | Should -Not -Match "`u202F"
            $content | Should -Not -Match "`u2039"
            $content | Should -Not -Match "`u203A"
            $content | Should -Not -Match "`u00AB"
            $content | Should -Not -Match "`u00BB"
            $content | Should -Not -Match "`u2192"
            $content | Should -Not -Match "`u2190"
            $content | Should -Not -Match "`u21D2"
            $content | Should -Not -Match "`u21D0"
            $content | Should -Not -Match "`u00B0"
            $content | Should -Not -Match "`u00A9"
            $content | Should -Not -Match "`u00AE"
            $content | Should -Not -Match "`u2122"
            $content | Should -Not -Match "`u200B"

            # Confirm ASCII replacements exist
            $content | Should -Match '"CurlyQuotesTest...Here"'
            $content | Should -Match "Range - 1 to 10"
            $content | Should -Match "Pause - wait"
            $content | Should -Match "\* Item one"
            $content | Should -Match "Forward -> Back <-"
            $content | Should -Match "Implies => <="
            $content | Should -Match "Temperature 30 deg"
            $content | Should -Match "Copyright (c)"
            $content | Should -Match "Registered (R)"
            $content | Should -Match "Trademark (TM)"
        }
    }
}


