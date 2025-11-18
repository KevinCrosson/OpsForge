# Test-Encoding.ps1
param (
    [string]$Root = ".",
    [string[]]$Extensions = @(".ps1", ".txt", ".md", ".json", ".csv")
)

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

$files = Get-ChildItem -Path $Root -Recurse -File | Where-Object {
    $Extensions -contains $_.Extension.ToLower()
}

foreach ($file in $files) {
    $bytes = [System.IO.File]::ReadAllBytes($file.FullName)

    # UTF-8 BOM is EF BB BF
    $hasBom = ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)

    if ($hasBom) {
        Write-Warning "❌ BOM still present: $($file.FullName)"
    } else {
        Write-Host "✅ UTF-8 without BOM: $($file.FullName)" -ForegroundColor Green
    }
}
