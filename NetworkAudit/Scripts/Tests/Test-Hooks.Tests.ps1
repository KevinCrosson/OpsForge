<#
.SYNOPSIS
    Cross-platform Pester tests for Git pre-commit hook hygiene.

.DESCRIPTION
    - Validates that pre-commit hooks exist (sh/bash for Linux/macOS, PowerShell for Windows).
    - Confirms they call Test-Encoding.ps1 for BOM hygiene enforcement.
    - Ensures commits are rejected when hygiene fails (simulated).
    - Compatible with Pester v3 syntax (used in PowerShell 5.1).
#>

Import-Module Pester -ErrorAction Stop

# Root project path
$Root     = (Get-Location).Path
# Paths to possible hook files
$HookPath = Join-Path $Root ".git/hooks/pre-commit"
$HookPS1  = "$HookPath.ps1"

Describe "Git pre-commit hook hygiene" {

    # --- Test 1: Hook existence ---
    It "Should exist in .git/hooks" {
        # Explicitly evaluate both paths and OR them (Pester v3 safe)
        $HookExists = (Test-Path $HookPath) -or (Test-Path $HookPS1)
        $HookExists | Should Be $true
    }

    # --- Test 2: Hook permissions ---
    It "Should be executable (not read-only)" {
        if (Test-Path $HookPath) {
            $Perms = Get-Item $HookPath
            ($Perms.Attributes -band [System.IO.FileAttributes]::ReadOnly) | Should Be 0
        }
        elseif (Test-Path $HookPS1) {
            $Perms = Get-Item $HookPS1
            ($Perms.Attributes -band [System.IO.FileAttributes]::ReadOnly) | Should Be 0
        }
    }

    # --- Test 3: Hook content ---
    It "Should call Test-Encoding.ps1" {
        if (Test-Path $HookPath) {
            $HookContent = Get-Content $HookPath -Raw
            $HookContent | Should Match "Test-Encoding.ps1"
        }
        elseif (Test-Path $HookPS1) {
            $HookContent = Get-Content $HookPS1 -Raw
            $HookContent | Should Match "Test-Encoding.ps1"
        }
    }

    # --- Test 4: Commit hygiene enforcement ---
    Context "Commit hygiene enforcement" {
        BeforeAll {
            # Create a deliberately dirty file (missing BOM)
            $TestFile = Join-Path $Root "Scripts\Tests\NoBomFile.ps1"
            $Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
            [System.IO.File]::WriteAllText($TestFile, "Write-Host 'No BOM'", $Utf8NoBom)
        }

        It "Should reject commit when hygiene fails" {
            if (Test-Path $HookPS1) {
                # Capture all output lines as a single string
                $Result = (& $HookPS1 2>&1 | Out-String).Trim()
            }
            elseif (Test-Path $HookPath) {
                $Result = (bash $HookPath 2>&1 | Out-String).Trim()
            }
            else {
                throw "No pre-commit hook found."
            }

            # Assert that the blocking message is present anywhere in the output
            $Result | Should Match "Pre-commit blocked"
        }

        AfterAll {
            # Clean up test file
            Remove-Item (Join-Path $Root "Scripts\Tests\NoBomFile.ps1") -Force
        }
    }
}

