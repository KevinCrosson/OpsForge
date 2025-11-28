# This is a test script with corrupted symbols

Write-Host "Hello World"         # U+201C and U+201D smart quotes
Write-Host 'It's working'        # U+2018 and U+2019 curly apostrophe
Write-Host "Path -> C:\Scripts"   # U+2192 arrow
Write-Host "Temp - Folder"       # U+2013 en dash
Write-Host "Temp - Folder"       # U+2014 em dash
Write-Host "Loading..."            # U+2026 ellipsis
Write-Host "* Item 1"            # U+2022 bullet
Write-Host "`u{200B}"            # Zero-width space (invisible)
Write-Host "`u{FEFF}"            # BOM (invisible)
Write-Host "`It's broken`"       # Backtick + U+2019 curly apostrophe (confusion case)

# End of test

