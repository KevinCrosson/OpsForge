# ------------------------------------------------------------
# Assert-SymbolReplacements.ps1
# ------------------------------------------------------------
# PURPOSE:
#   Provides a reusable helper function for Pester tests.
#   It validates that Repair-CorruptedSymbols.ps1:
#     1. Logs all expected Unicode replacements in dry-run mode
#     2. Removes Unicode symbols and inserts ASCII equivalents in live repair
#
# USAGE:
#   In your test file (e.g., CorruptedSample2.Test.ps1):
#     . "$PSScriptRoot\Helpers\Assert-SymbolReplacements.ps1"
#     Assert-SymbolReplacements -LogContent $log -FileContent $content
#
# PARAMETERS:
#   -LogContent   : The raw contents of SymbolFix.log (string)
#   -FileContent  : The raw contents of the repaired file (string)
#
# NOTES:
#   - If LogContent is provided, dry-run assertions are executed.
#   - If FileContent is provided, live repair assertions are executed.
#   - You can pass both to validate both contexts in one call.
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
        # List of all Unicode symbols expected in the log
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
            "U\+2039",  # Single angle quote (<)
            "U\+203A",  # Single angle quote (>)
            "U\+00AB",  # Guillemets (<<)
            "U\+00BB",  # Guillemets (>>)
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
        # Unicode symbols that must NOT appear in the repaired file
        $unicodeSymbols = @(
            "`uFEFF","`u201C","`u201D","`u2018","`u2019",
            "`u2013","`u2014","`u2026","`u2022","`u00A0","`u202F",
            "`u2039","`u203A","`u00AB","`u00BB","`u2192","`u2190",
            "`u21D2","`u21D0","`u00B0","`u00A9","`u00AE","`u2122","`u200B"
        )

        foreach ($unicode in $unicodeSymbols) {
            $FileContent | Should -Not -Match $unicode
        }

        # ASCII equivalents that MUST appear after repair
        $FileContent | Should -Match '"CurlyQuotesTest...Here"'   # Curly quotes + ellipsis fixed
        $FileContent | Should -Match "Range - 1 to 10"            # En dash fixed
        $FileContent | Should -Match "Pause - wait"               # Em dash fixed
        $FileContent | Should -Match "\* Item one"                # Bullet replaced with *
        $FileContent | Should -Match "Forward -> Back <-"         # Arrows replaced
        $FileContent | Should -Match "Implies => <="              # Double arrows replaced
        $FileContent | Should -Match "Temperature 30 deg"         # Degree replaced
        $FileContent | Should -Match "Copyright (c)"              # (c) replaced
        $FileContent | Should -Match "Registered (R)"             # (R) replaced
        $FileContent | Should -Match "Trademark (TM)"             # (TM) replaced
    }
}


