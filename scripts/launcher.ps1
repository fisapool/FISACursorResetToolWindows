# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "❌ This script must be run as Administrator"
    Write-Host "Please run the reset.bat file instead"
    pause
    exit 1
}

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$psScript = Join-Path $scriptPath "reset.ps1"

# Run PowerShell script
if (Test-Path $psScript) {
    powershell.exe -ExecutionPolicy Bypass -File $psScript $args
} else {
    Write-Error "PowerShell script not found: $psScript"
}
