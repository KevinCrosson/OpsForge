$Files = @(
    "$PSScriptRoot\..\Docs\README.md",
    "$PSScriptRoot\..\VERSION.txt",
    "$PSScriptRoot\..\CHANGELOG.md"
)

$Output = "$PSScriptRoot\..\Build\DocsBundle.zip"
Compress-Archive -Path $Files -DestinationPath $Output -Force
Write-Host "Documentation bundle created at: $Output"
