<#
.SYNOPSIS
Pester test suite for Test-SymbolMap.ps1

.DESCRIPTION
Runs structured unit tests against SymbolMap.json using the harness logic.
Ensures JSON validity, duplicate detection, and replacement integrity.
Produces structured pass/fail results for CI.
#>

# Import Pester
Import-Module Pester -ErrorAction Stop

# Path to harness and map
$HarnessPath = "$PSScriptRoot\Test-SymbolMap.ps1"
$MapPath     = "$PSScriptRoot\..\Maintenance\SymbolMap.json"

Describe "SymbolMap Validation" {

    Context "JSON validity" {
        It "SymbolMap.json should parse correctly" {
            { Get-Content $MapPath -Raw -Encoding UTF8 | ConvertFrom-Json } | Should -Not -Throw
        }
    }

    Context "Duplicate detection" {
        It "Should not contain duplicate keys" {
            $RawMap = Get-Content $MapPath -Raw -Encoding UTF8 | ConvertFrom-Json
            $Keys = $RawMap.PSObject.Properties.Name
            $Keys.Count | Should -Be ($Keys | Select-Object -Unique).Count
        }
    }

    Context "Replacement integrity" {
        It "All replacements should be non-null" {
            $RawMap = Get-Content $MapPath -Raw -Encoding UTF8 | ConvertFrom-Json
            foreach ($key in $RawMap.PSObject.Properties.Name) {
                $RawMap.$key | Should -Not -BeNullOrEmpty
            }
        }
    }

    Context "Harness execution" {
        It "Harness should run without errors" {
            { & $HarnessPath } | Should -Not -Throw
        }
    }
}
