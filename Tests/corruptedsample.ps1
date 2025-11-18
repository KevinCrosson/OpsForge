# Create a sample file with corrupted symbols
$testPath = "C:\NetworkAudit\Tests\CorruptedSample.ps1"
New-Item -ItemType File -Path $testPath -Force | Out-Null
Set-Content -Path $testPath -Value @'
Write-Host "Task ÃƒÂ¢Ã…â€œÃ¢â‚¬Å“ completed ÃƒÂ¢Ã¢â‚¬Â Ã¢â‚¬â„¢ next step ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Â review logs"
# Comment: ÃƒÂ¢Ã¢â€šÂ¬Ã‹Å“QuotedÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ and ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œDoubleÃƒÂ¢Ã¢â€šÂ¬ 
'@ -Encoding UTF8
