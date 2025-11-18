function Write-DevInfo {
    param ($Message)
    Write-Host "[DevTasks] $Message" -ForegroundColor Yellow
}

function Write-DevVerbose {
    param ($Message)
    if ($Verbose) {
        Write-Host "[VERBOSE] $Message" -ForegroundColor Cyan
    }
}