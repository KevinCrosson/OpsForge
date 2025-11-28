# ------------------------------------------------------------
# SymbolHygiene.Tests.psm1
# ------------------------------------------------------------
# PURPOSE:
#   Provides reusable Pester assertion helpers for validating
#   Repair-CorruptedSymbols.ps1 across multiple projects.
#
# CONTENTS:
#   - Assert-SymbolReplacements : Validates dry-run logs and live repair content
#
# USAGE:
#   Import-Module ./Modules/SymbolHygiene.Tests/SymbolHygiene.Tests.psm1
#   Assert-SymbolReplacements -LogContent $log -FileContent $content
#
# NOTES:
#   - Designed for CI/CD pipelines and local validation
#   - Centralizes symbol coverage so you only update one place
# ------------------------------------------------------------

function Assert-SymbolReplacements {
    param(
        [string]$LogContent,
        [string]$FileContent
    )

    # --------------------------------------------------------
    # DRY-RUN ASSERTIONS
    # --------------------------------------------------------
    if ($LogContent) {
        $expectedSymbols = @(
            "U\+FEFF",  # BOM
            "U\+201C",  # Curly double quote (open)
            "U\+201D",  # Curly double quote (close)
            "U\+2018",  # Curly single quote (open)
            "U\+2019",  # Curly single quote (close)
            "U\+2013",  # En dash
            "U\+2014",  # Em dash
            "U\+2026",  # Ellipsis
            "U\+2022",  # Bullet
            "U\+00A0",  # Non-breaking space
            "U\+202F",  # Narrow NBSP
            "U\+2039",  # Single angle quote (‹)
            "U\+203A",  # Single angle quote (›)
            "U\+00AB",  # Guillemets («)
            "U\+00BB",  # Guillemets (»)
            "U\+2192",  # Arrow right
            "U\+2190",  # Arrow left
            "U\+21D2",  # Double arrow right
            "U\+21D0",  # Double arrow left
            "U\+00B0",  # Degree
            "U\+00A9",  # Copyright
            "U\+00AE",  # Registered
            "U\+2122",  # Trademark
            "U\+200B"   # Zero-width space
        )

        foreach ($symbol in $expectedSymbols) {
            $LogContent | Should -Match $symbol
        }
    }

    # --------------------------------------------------------
    # LIVE REPAIR ASSERTIONS
    # --------------------------------------------------------
    if ($FileContent) {
        $unicodeSymbols = @(
            "`uFEFF","`u201C","`u201D","`u2018","`u2019",
            "`u2013","`u2014","`u2026","`u2022","`u00A0","`u202F",
            "`u2039","`u203A","`u00AB","`u00BB","`u2192","`u2190",
            "`u21D2","`u21D0","`u00B0","`u00A9","`u00AE","`u2122","`u200B"
        )

        foreach ($unicode in $unicodeSymbols) {
            $FileContent | Should -Not -Match $unicode
        }

        # Confirm ASCII replacements exist
        $FileContent | Should -Match '"CurlyQuotesTest...Here"'   # Curly quotes + ellipsis fixed
        $FileContent | Should -Match "Range - 1 to 10"            # En dash fixed
        $FileContent | Should -Match "Pause - wait"               # Em dash fixed
        $FileContent | Should -Match "\* Item one"                # Bullet replaced
        $FileContent | Should -Match "Forward -> Back <-"         # Arrows replaced
        $FileContent | Should -Match "Implies => <="              # Double arrows replaced
        $FileContent | Should -Match "Temperature 30 deg"         # Degree replaced
        $FileContent | Should -Match "Copyright (c)"              # © replaced
        $FileContent | Should -Match "Registered (R)"             # ® replaced
        $FileContent | Should -Match "Trademark (TM)"             # ™ replaced
    }
}

