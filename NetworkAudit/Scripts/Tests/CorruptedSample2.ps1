# ------------------------------------------------------------
# CorruptedSample2.ps1
# ------------------------------------------------------------
# PURPOSE:
#   This file is deliberately corrupted with non‑ASCII symbols
#   (curly quotes, ellipsis, BOM, NBSP, arrows, etc.) so that
#   Repair-CorruptedSymbols.ps1 can detect and replace them.
#
# NOTE:
#   Do NOT "fix" this file manually - it is meant to stay broken
#   so the repair script and Pester tests have something to validate.
# ------------------------------------------------------------

# Curly quotes (U+201C / U+201D)
Write-Host "Hello World"      

# Curly single quotes (U+2018 / U+2019)
Write-Host 'Test String'      

# En dash (U+2013)
Write-Host "Range - 1 to 10"  

# Em dash (U+2014)
Write-Host "Pause - wait"     

# Ellipsis (U+2026)
Write-Host "Loading..."         

# Bullet (U+2022)
Write-Host "* Item one"       

# Non-breaking space (U+00A0)
Write-Host "Value Here"       

# Narrow NBSP (U+202F)
Write-Host "Value Here"       

# Guillemets and angle quotes (U+00AB / U+00BB / U+2039 / U+203A)
Write-Host "<<Left>> <Inner> >Outer<"  

# Arrows (U+2192 / U+2190)
Write-Host "Forward -> Back <-"        

# Double arrows (U+21D2 / U+21D0)
Write-Host "Implies => <="             

# Degree (U+00B0)
Write-Host "Temperature 30 deg"         

# Copyright (U+00A9)
Write-Host "Copyright (c)"             

# Registered (U+00AE)
Write-Host "Registered (R)"            

# Trademark (U+2122)
Write-Host "Trademark (TM)"             

# Zero-width space (U+200B)
Write-Host "ZeroWidthSpaceHere"     

# BOM (U+FEFF) deliberately placed at start of file
Write-Host "BOMHere"                 

# Mixed corruption line
Write-Host "CurlyQuotesTest...Here"    # curly quotes + ellipsis

