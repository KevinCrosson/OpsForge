<#
.SYNOPSIS
    Automates tagging and pushing a new release with semantic versioning.

.DESCRIPTION
    - Reads current version from Docs\VERSION
    - Bumps major, minor, or patch depending on user input
    - Commits updated VERSION, README.md, CHANGELOG.md
    - Creates a Git tag (vX.Y.Z)
    - Pushes commits and tag to origin
    - Triggers release.yml workflow in GitHub Actions

.PARAMETER Bump
    Which part of the version to bump: Major, Minor, or Patch.
    Defaults to Patch if not specified.
#>

param(
    [ValidateSet("Major","Minor","Patch")]
    [string]$Bump = "Patch"
)

Write-Output "🚀 Starting release tagging process (bump: $Bump)..."

$Root        = (Get-Location).Path
$VersionPath = Join-Path $Root "Docs\VERSION"

# --- Step 1: Read current version ---
if (-not (Test-Path $VersionPath)) {
    Write-Error "VERSION file not found at $VersionPath"
    exit 1
}
$current = (Get-Content $VersionPath -Raw).Trim()
$parts   = $current.Split(".")
if ($parts.Count -ne 3) {
    Write-Error "VERSION file must be in format x.y.z"
    exit 1
}

# --- Step 2: Bump version based on parameter ---
$major = [int]$parts[0]
$minor = [int]$parts[1]
$patch = [int]$parts[2]

switch ($Bump) {
    "Major" {
        $major++
        $minor = 0
        $patch = 0
    }
    "Minor" {
        $minor++
        $patch = 0
    }
    "Patch" {
        $patch++
    }
}

$newVersion = "$major.$minor.$patch"

# --- Step 3: Update VERSION file ---
Set-Content -Path $VersionPath -Value $newVersion -Encoding UTF8
Write-Output "✅ Version bumped to $newVersion"

# --- Step 4: Run documentation bundler ---
Write-Output "📦 Running Bundle-Docs.ps1 to regenerate docs..."
& Scripts\Dispatchers\Bundle-Docs.ps1

# --- Step 5: Commit changes ---
Write-Output "📜 Committing updated docs..."
git add README.md CHANGELOG.md VERSION Docs\VERSION Docs\README.md Docs\CHANGELOG.md
git commit -m "Release v${newVersion}: updated docs and version bump ($Bump)"

# --- Step 6: Create Git tag ---
$tagName = "v${newVersion}"
Write-Output "🏷️ Creating Git tag $tagName..."
git tag $tagName

# --- Step 7: Push commits and tag ---
Write-Output "⬆️ Pushing commits and tag to origin..."
git push origin main
git push origin $tagName

Write-Output "✅ Release process complete. GitHub Actions will now run release.yml for $tagName."

