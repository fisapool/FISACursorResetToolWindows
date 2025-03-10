<<<<<<< HEAD
# Create directory structure
$baseDir = $PSScriptRoot
if (-not $baseDir) {
    $baseDir = Get-Location
}
$scriptsDir = Join-Path $baseDir "scripts"

Write-Host "Creating directory structure..."
Write-Host "Base directory: $baseDir"
Write-Host "Scripts directory: $scriptsDir"

# Create directories if they don't exist
New-Item -ItemType Directory -Force -Path $scriptsDir | Out-Null

# Create reset.ps1
$resetPsContent = @'
#Requires -Version 5.0
#Requires -RunAsAdministrator

# Show menu function
function Show-Menu {
    Clear-Host
    Write-Host "================================"
    Write-Host "    Cursor Reset Tool Menu      "
    Write-Host "================================"
    Write-Host
    Write-Host "A) Reset Cursor Trial"
    Write-Host "B) Exit"
    Write-Host
    Write-Host "================================"
    Write-Host
}

# Reset function
function Reset-CursorTrial {
    try {
        Write-Host "🔄 Starting Cursor reset..."
        
        # Check if Cursor is running
        $cursorProcess = Get-Process -Name "*cursor*" -ErrorAction SilentlyContinue
        if ($cursorProcess) {
            Write-Host "Found running Cursor process. Attempting to close..."
            $cursorProcess | Stop-Process -Force
            Start-Sleep -Seconds 2
        }

        # Get config path
        $configPath = Join-Path $env:APPDATA "Cursor"
        $storagePath = Join-Path $configPath "storage.json"

        # Backup existing config
        if (Test-Path $storagePath) {
            $backupPath = "$storagePath.bak"
            Copy-Item $storagePath $backupPath -Force
            Write-Host "✅ Config backup created"
        }

        # Generate new IDs
        $newConfig = @{
            "telemetry.machineId" = [guid]::NewGuid().ToString("N")
            "telemetry.macMachineId" = [guid]::NewGuid().ToString("N")
            "telemetry.devDeviceId" = [guid]::NewGuid().ToString()
        }

        # Save new config
        $newConfig | ConvertTo-Json | Set-Content -Path $storagePath -Force
        Write-Host "✅ New device IDs generated and saved"

        # Disable auto-updates
        $updaterPath = Join-Path $env:LOCALAPPDATA "cursor-updater"
        if (Test-Path $updaterPath) {
            Remove-Item $updaterPath -Recurse -Force
        }
        "" | Set-Content -Path $updaterPath -Force
        Write-Host "✅ Auto-updates disabled"

        Write-Host "`n✨ Reset completed successfully!"
        Write-Host "You can now start Cursor editor"
        pause
    } catch {
        Write-Host "❌ Error during reset: $($_.Exception.Message)"
        pause
    }
}

# Handle menu choice
function Handle-MenuChoice {
    param (
        [string]$Choice
    )
    
    switch ($Choice.ToUpper()) {
        'A' {
            Reset-CursorTrial
            return $true
        }
        'B' {
            return $false
        }
        default {
            Write-Host "Invalid choice. Please try again."
            Start-Sleep -Seconds 1
            return $true
        }
    }
}

# Main menu loop
function Main-Menu {
    $continue = $true
    while ($continue) {
        Show-Menu
        $choice = Read-Host "Enter your choice"
        $continue = Handle-MenuChoice $choice
    }
}

# Start the menu
Main-Menu
'@

# Create launcher.ps1
$launcherContent = @'
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
'@

# Create reset.bat
$batchContent = @'
@echo off
:: Check for admin privileges
net session >nul 2>&1
if %errorLevel% == 0 (
    goto :run
) else (
    echo Requesting administrative privileges...
    goto :UACPrompt
)

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    exit /B

:run
    cd /d "%~dp0\scripts"
    powershell.exe -ExecutionPolicy Bypass -NoProfile -File "launcher.ps1" %*
    if errorlevel 1 pause
    exit /B
'@

# Write files
Write-Host "Creating script files..."
Set-Content -Path (Join-Path $scriptsDir "reset.ps1") -Value $resetPsContent -Force
Set-Content -Path (Join-Path $scriptsDir "launcher.ps1") -Value $launcherContent -Force
Set-Content -Path (Join-Path $baseDir "reset.bat") -Value $batchContent -Encoding ASCII -Force

# Create shortcut
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut([System.IO.Path]::Combine($baseDir, "Cursor Reset.lnk"))
$Shortcut.TargetPath = [System.IO.Path]::Combine($baseDir, "reset.bat")
$Shortcut.IconLocation = "shell32.dll,131"
$Shortcut.Save()

Write-Host "✅ Setup completed successfully!"
Write-Host "You can now run 'Cursor Reset' shortcut to start the tool."
=======
# Setup script for FISA Cursor Reset Tool
$ErrorActionPreference = 'Stop'

# Create desktop shortcut
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\FISA Cursor Reset.lnk")
$Shortcut.TargetPath = "$PSScriptRoot\reset.bat"
$Shortcut.WorkingDirectory = "$PSScriptRoot"
$Shortcut.IconLocation = "shell32.dll,131"
$Shortcut.Save()

Write-Host "✅ Setup completed successfully!" -ForegroundColor Green
Write-Host "You can now use the shortcut on your desktop." -ForegroundColor Yellow
pause 
>>>>>>> 28e8a8c164d66a7ec0359f699fdfe83d80ecd2af
