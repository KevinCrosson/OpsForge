$Root        = (Get-Location).Path
$VersionPath = Join-Path $Root "Docs\VERSION"
$OutputPath  = Join-Path $Root "VERSION"

$current = (Get-Content $VersionPath -Raw).Trim()

# Split into major.minor.patch
$parts = $current.Split(".")
if ($parts.Count -ne 3) {
    Write-Error "VERSION file must be in format x.y.z"
    exit 1
}

$major = [int]$parts[0]
$minor = [int]$parts[1]
$patch = [int]$parts[2] + 1

$newVersion = "$major.$minor.$patch"

# Write new version
Set-Content -Path $VersionPath -Value $newVersion -Encoding UTF8
Copy-Item $VersionPath $OutputPath -Force

Write-Output "✅ Version bumped to $newVersion"