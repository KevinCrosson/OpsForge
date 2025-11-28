<#
.SYNOPSIS
    Master dispatcher for running all major NetworkAudit modules in a single sweep.

.DESCRIPTION
    Executes validation, metadata, CI, diagnostics, cleanup, and export modules.
    Supports dry-run simulation and logs each module's execution with timestamps to Logs/ci/.
    Designed for CI pipelines, scheduled tasks, or manual sweeps.

.PARAMETER Verbose
    Enables detailed output from each module.

.PARAMETER DryRun
    Simulates execution without running scripts. Useful for CI testing or preview.

.EXAMPLE
    .\Dispatch-All.ps1 -Verbose -DryRun
#>

[CmdletBinding()]
param (
    [switch]$Verbose,
    [switch]$DryRun
)

# --- Resolve Paths ---
$Root     = Resolve-Path "$PSScriptRoot\..\.."
$LogDir   = Join-Path $Root "Logs\ci"
$LogFile  = Join-Path $LogDir "DispatcherLog_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

# --- Ensure Log Directory Exists ---
if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}

# --- Logger Function ---
function Write-Log {
    param ([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "$timestamp | $Message"
    Add-Content -Path $LogFile -Value $entry
    Write-Host $entry
}

# --- Module Executor ---
function Invoke-Module {
    param (
        [string]$Label,
        [string]$ScriptPath
    )

    Write-Log "▶ $Label"
    if ($DryRun) {
        Write-Log "DryRun: Would invoke ${ScriptPath}"
        return
    }

    if (Test-Path $ScriptPath) {
        try {
            & $ScriptPath -Verbose:$Verbose
            Write-Log "✅ Completed: ${ScriptPath}"
        } catch {
            Write-Log "❌ Error in ${ScriptPath}: $_"
        }
    } else {
        Write-Log "⚠️ Missing: ${ScriptPath}"
    }
}

# --- Dispatch Sequence ---

Invoke-Module "Validating folder structure..." `
              "$Root\Scripts\Validate\Validate-FolderStructure.ps1"

Invoke-Module "Generating metadata and changelog..." `
              "$Root\Scripts\Metadata\Generate-AllMetadata.ps1"

Invoke-Module "Running CI pipeline checks..." `
              "$Root\Scripts\CI\Run-CiPipeline.ps1"

Invoke-Module "Fixing broken imports and cleaning up..." `
              "$Root\Scripts\Maintenance\DevRunner-FixAndClean.ps1"

Invoke-Module "Logging active TCP connections..." `
              "$Root\Scripts\Network\Log-ActiveConnections.ps1"

Invoke-Module "Exporting classified connections to JSON..." `
              "$Root\Scripts\Network\Export-ClassifiedConnections.ps1"

Invoke-Module "Capturing live packets..." `
              "$Root\Scripts\Dispatchers\Dispatch-CapturePackets.ps1"

Invoke-Module "Scanning Bluetooth devices..." `
              "$Root\Scripts\Bluetooth\Scan-BluetoothDevices.ps1"

Invoke-Module "Monitoring system health..." `
              "$Root\Scripts\Monitoring\Monitor-SystemHealth.ps1"

Invoke-Module "Verifying script signatures and trust levels..." `
              "$Root\Scripts\Security\Verify-ScriptSignatures.ps1"

Invoke-Module "Checking license headers and contributor agreements..." `
              "$Root\Scripts\Compliance\Validate-LicenseHeaders.ps1"

Invoke-Module "Testing SMTP configuration..." `
              "$Root\Scripts\Email\Test-SMTPConfig.ps1"

Invoke-Module "Summarizing dispatcher logs for dashboard..." `
              "$Root\Scripts\CI\Summarize-DispatcherLogs.ps1"

# --- Completion Banner ---
Write-Log "✅ Full system sweep complete."
Write-Host "`n🧾 Dispatcher log saved to: $LogFile" -ForegroundColor Green
