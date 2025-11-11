function ConvertTo-Markdown {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [hashtable]$Metadata
    )

    $lines = @()
    $lines += "# Metadata Summary"
    $lines += ""

    foreach ($key in $Metadata.Keys) {
        $value = $Metadata[$key]
        $lines += "## $key"
        $lines += "$value"
        $lines += ""
    }

    return $lines -join "`n"
}