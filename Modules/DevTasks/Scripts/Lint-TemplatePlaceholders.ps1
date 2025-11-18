$Template = Get-Content "$PSScriptRoot\..\Docs\README_Template.md" -Raw
$Placeholders = [regex]::Matches($Template, "{{(.*?)}}") | ForEach-Object { $_.Groups[1].Value }

$Metadata = Generate-AllMetadata
$Missing = $Placeholders | Where-Object { -not $Metadata.ContainsKey($_) }

if ($Missing) {
    Write-Warning "Unresolved placeholders: $($Missing -join ', ')"
    exit 1
} else {
    Write-Host "Ã¢Å“â€¦ All placeholders resolved."
}
