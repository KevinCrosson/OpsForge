@{
    # ------------------------------------------------------------
    # SymbolHygiene.Tests.psd1
    # ------------------------------------------------------------
    # PURPOSE:
    #   Module manifest for SymbolHygiene.Tests
    #   Provides reusable Pester assertion helpers for validating
    #   Repair-CorruptedSymbols.ps1 across multiple projects.
    #
    # USAGE:
    #   Place this manifest alongside SymbolHygiene.Tests.psm1
    #   Import with: Import-Module SymbolHygiene.Tests
    # ------------------------------------------------------------

    # General metadata
    RootModule        = 'SymbolHygiene.Tests.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = 'b2f6a5a1-1234-4d89-9abc-5678def90123'  # generate a new GUID if publishing
    Author            = 'Kevin Crosson'
    CompanyName       = 'NetworkAudit Project'
    Copyright         = '(c) 2025 Kevin Crosson. All rights reserved.'
    Description       = 'Reusable Pester assertion helpers for symbol hygiene enforcement across CI/CD pipelines.'

    # PowerShell compatibility
    PowerShellVersion = '5.1'
    CompatiblePSEditions = @('Desktop','Core')

    # Functions to export
    FunctionsToExport = @('Assert-SymbolReplacements')
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()

    # Private data (optional, for publishing)
    PrivateData = @{
        PSData = @{
            Tags        = @('Pester','CI','Encoding','SymbolHygiene','Testing')
            LicenseUri  = 'https://opensource.org/licenses/MIT'
            ProjectUri  = 'https://github.com/your-org/NetworkAudit'
            ReleaseNotes= 'Initial release of SymbolHygiene.Tests module.'
        }
    }
}

