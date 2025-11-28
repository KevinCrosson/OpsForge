@{
    # ------------------------------------------------------------
    # General Module Metadata
    # ------------------------------------------------------------
    # RootModule: The main script file (.psm1) that contains your functions.
    RootModule        = 'AutoDocs.psm1'

    # ModuleVersion: Semantic version of your module.
    # Update this when you make changes (Major.Minor.Patch).
    ModuleVersion     = '1.0.0'

    # GUID: Unique identifier for the module.
    # Generate one with [guid]::NewGuid() if publishing to PowerShell Gallery.
    GUID              = '00000000-0000-0000-0000-000000000000'

    # Author: Your name or organization.
    Author            = 'Kevin Crosson'

    # CompanyName: Optional, can be left blank or set to your org.
    CompanyName       = 'Independent'

    # Copyright: Legal notice for distribution.
    Copyright         = '(c) 2025 Kevin Crosson. All rights reserved.'

    # Description: Short summary of what the module does.
    Description       = 'Standalone documentation bundler for CI/CD workflows. Generates README.md, updates CHANGELOG.md, bumps VERSION, and copies LICENSE.'

    # ------------------------------------------------------------
    # Functions Exported by the Module
    # ------------------------------------------------------------
    # These are the functions defined in AutoDocs.psm1 that will be available
    # when someone imports the module.
    FunctionsToExport = @(
        'Invoke-ReadmeGeneration',
        'Invoke-ChangelogUpdate',
        'Invoke-VersionBump',
        'Invoke-LicenseCopy',
        'Invoke-BundleDocs'
    )

    # CmdletsToExport: Leave empty unless you wrap native cmdlets.
    CmdletsToExport   = @()

    # VariablesToExport: Leave empty unless you want to expose variables.
    VariablesToExport = @()

    # AliasesToExport: Leave empty unless you define aliases in your module.
    AliasesToExport   = @()

    # ------------------------------------------------------------
    # Module Dependencies
    # ------------------------------------------------------------
    # RequiredModules: List other modules this one depends on.
    # Example: @('Pester') if you want doc tests to run automatically.
    RequiredModules   = @()

    # ------------------------------------------------------------
    # PowerShell Compatibility
    # ------------------------------------------------------------
    # PowerShellVersion: Minimum version required to run this module.
    PowerShellVersion = '5.1'

    # CompatiblePSEditions: Core, Desktop, or both.
    CompatiblePSEditions = @('Core','Desktop')

    # ------------------------------------------------------------
    # Additional Metadata (Optional)
    # ------------------------------------------------------------
    # PrivateData: Custom metadata, often used for publishing.
    PrivateData = @{
        PSData = @{
            Tags        = @('docs','automation','ci','readme','changelog','versioning')
            LicenseUri  = 'https://opensource.org/licenses/MIT'
            ProjectUri  = 'https://github.com/yourusername/AutoDocs'
            ReleaseNotes= 'Initial release of AutoDocs module.'
        }
    }
}

