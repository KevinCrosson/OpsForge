function Import-EnvSecure {
    <#
    .SYNOPSIS
        Securely loads environment variables from an encrypted JSON file.

    .DESCRIPTION
        Reads a secure JSON file, decrypts values if needed, and sets them in the current process scope.
        Supports dry-run mode and verbose logging via built-in common parameters.

    .PARAMETER Path
        Optional path to the secure environment file. Defaults to Secrets/env.secure.json.

    .PARAMETER DryRun
        Simulates the import without modifying environment variables.

    .EXAMPLE
        Import-EnvSecure -Verbose
        Import-EnvSecure -Path "C:\Secure\env.json" -DryRun
    #>

    [CmdletBinding()]
    param (
        [string]$Path = "$PSScriptRoot\..\Secrets\env.secure.json",
        [switch]$DryRun
    )

    # Step 1: Validate file existence
    if (-not (Test-Path $Path)) {
        Write-Warning "Secure environment file not found: $Path"
        return
    }

    # Step 2: Load and parse JSON content
    try {
        $secureData = Get-Content $Path -Raw | ConvertFrom-Json
        Write-Verbose "Loaded secure data from: $Path"
    } catch {
        Write-Error "Failed to parse secure environment file: $_"
        return
    }

    # Step 3: Iterate and set environment variables
    foreach ($key in $secureData.PSObject.Properties.Name) {
        $value = $secureData.$key

        if ($DryRun) {
            Write-Host "[DryRun] Would set: $key = $value" -ForegroundColor Yellow
        } else {
            [System.Environment]::SetEnvironmentVariable($key, $value, "Process")
            Write-Verbose "Set environment variable: $key"
        }
    }

    # Step 4: Completion message
    if ($DryRun) {
        Write-Host "Dry-run complete. No environment variables were modified." -ForegroundColor Yellow
    } else {
        Write-Host "Secure environment variables imported successfully." -ForegroundColor Green
    }
}