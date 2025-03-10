# Colors for output
$script:GREEN = [System.ConsoleColor]::Green
$script:RED = [System.ConsoleColor]::Red
$script:BLUE = [System.ConsoleColor]::Blue
$script:GRAY = [System.ConsoleColor]::Gray
$script:YELLOW = [System.ConsoleColor]::Yellow
$script:WHITE = [System.ConsoleColor]::White

# Configuration
$PACKAGE_VERSION = "0.44.11"
$CONFIG_DIR = "$env:USERPROFILE\.cursor-ai"
$LOG_FILE = "$CONFIG_DIR\cursor.log"

# Create config directory and log file
New-Item -ItemType Directory -Force -Path $CONFIG_DIR | Out-Null
if (-not (Test-Path $LOG_FILE)) {
    New-Item -ItemType File -Path $LOG_FILE | Out-Null
}

# Logging function
function Write-Log {
    param($Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp $Message" | Out-File -Append -FilePath $LOG_FILE
}

# Clear screen function
function Clear-Screen {
    Clear-Host
}

# Colors
$colors = @{
    Green  = "`e[32m"
    Red    = "`e[31m"
    Blue   = "`e[34m"
    Yellow = "`e[33m"
    Gray   = "`e[90m"
    Reset  = "`e[0m"
}

function Show-Banner {
    Clear-Host
    Write-Host ""
    Write-Host "  $($colors.Blue)╭───────────────────────────────╮$($colors.Reset)"
    Write-Host "  $($colors.Blue)│$($colors.Reset)      🖥️  CURSOR AI RESET      $($colors.Blue)│$($colors.Reset)"
    Write-Host "  $($colors.Blue)╰───────────────────────────────╯$($colors.Reset)"
    Write-Host ""
}

function Show-Menu {
    Write-Host "  $($colors.Gray)Options:$($colors.Reset)"
    Write-Host ""
    Write-Host "  $($colors.Green)⚡ [A]$($colors.Reset) Reset Cursor AI"
    Write-Host "     $($colors.Gray)Fresh installation and setup$($colors.Reset)"
    Write-Host ""
    Write-Host "  $($colors.Yellow)🔍 [C]$($colors.Reset) System Requirements"
    Write-Host "     $($colors.Gray)Verify system compatibility$($colors.Reset)"
    Write-Host ""
    Write-Host "  $($colors.Blue)📜 [D]$($colors.Reset) License Information"
    Write-Host "     $($colors.Gray)View terms and requirements$($colors.Reset)"
    Write-Host ""
    Write-Host "  $($colors.Blue)📋 [E]$($colors.Reset) Post-Install Guide"
    Write-Host "     $($colors.Gray)Setup completion steps$($colors.Reset)"
    Write-Host ""
    Write-Host "  $($colors.Red)✖ [Q]$($colors.Reset) Exit"
    Write-Host "     $($colors.Gray)Close the program$($colors.Reset)"
    Write-Host ""
}

# Check system requirements
function Test-SystemRequirements {
    Write-Host "`nChecking system requirements..." -ForegroundColor $BLUE
    
    $ram = (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB
    $freeSpace = (Get-PSDrive C).Free / 1GB
    $arch = (Get-WmiObject Win32_OperatingSystem).OSArchitecture
    
    Write-Host "`nSystem Requirements:" -ForegroundColor $GREEN
    Write-Host "  • RAM: ${ram:N2}GB / 4GB Required" -ForegroundColor $GRAY
    Write-Host "  • Free Space: ${freeSpace:N2}GB / 2GB Required" -ForegroundColor $GRAY
    Write-Host "  • Architecture: $arch" -ForegroundColor $GRAY
    Write-Host "  • Platform: Windows" -ForegroundColor $GRAY
    
    if ($ram -lt 4) {
        Write-Host "`n❌ Minimum 4GB RAM required" -ForegroundColor $RED
        return $false
    }
    
    if ($freeSpace -lt 2) {
        Write-Host "`n❌ Minimum 2GB free disk space required" -ForegroundColor $RED
        return $false
    }
    
    if ($arch -notlike "*64*") {
        Write-Host "`n❌ 64-bit Windows required" -ForegroundColor $RED
        return $false
    }
    
    return $true
}

# Install Cursor
function Install-Cursor {
    Write-Host "`nInstalling Cursor v$PACKAGE_VERSION" -ForegroundColor $BLUE
    
    $downloadUrl = "https://downloader.cursor.sh/builds/250103fqxdt5u9z/windows/nsis/x64"
    $installerPath = "$env:TEMP\cursor_setup.exe"
    
    Write-Host "Downloading Cursor..." -ForegroundColor $GRAY
    
    try {
        Invoke-WebRequest -Uri $downloadUrl -OutFile $installerPath
        Write-Host "Running installer..." -ForegroundColor $GRAY
        Start-Process -FilePath $installerPath -Wait
        Remove-Item -Path $installerPath -Force
    }
    catch {
        Write-Host "`n❌ Installation failed: $_" -ForegroundColor $RED
        return $false
    }
    
    Write-Host "`n✅ Installation completed successfully" -ForegroundColor $GREEN
    return $true
}

# Uninstall Cursor
function Uninstall-Cursor {
    Write-Host "`nUninstalling Cursor..." -ForegroundColor $BLUE
    
    $uninstallString = Get-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | 
                      Where-Object { $_.DisplayName -like "*Cursor*" } |
                      Select-Object -ExpandProperty UninstallString
    
    if ($uninstallString) {
        Start-Process -FilePath $uninstallString -Wait
        Write-Host "`n✅ Uninstallation completed!" -ForegroundColor $GREEN
    }
    else {
        Write-Host "`n❌ Cursor not found or already uninstalled" -ForegroundColor $YELLOW
    }
}

# Main loop
while ($true) {
    Show-Banner
    Show-Menu
    
    $choice = Read-Host "Select an option"
    
    switch ($choice.ToUpper()) {
        'A' {
            Clear-Screen
            Show-Banner
            if (Test-SystemRequirements) {
                Uninstall-Cursor
                Install-Cursor
            }
            Write-Host "`nPress Enter to return to main menu..." -ForegroundColor $GRAY
            $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
        }
        'C' {
            Clear-Screen
            Show-Banner
            Test-SystemRequirements
            Write-Host "`nPress Enter to return to main menu..." -ForegroundColor $GRAY
            $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
        }
        'D' {
            Clear-Screen
            Show-Banner
            Write-Host "`nLicense Requirements" -ForegroundColor $BLUE
            Write-Host "• Sign Up again using NEW Gmail Account"
            Write-Host "• If there Trial Limit, you can revisit this Terminal and start again the process"
            Write-Host "`nPress Enter to return to main menu..." -ForegroundColor $GRAY
            $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
        }
        'E' {
            Clear-Screen
            Show-Banner
            Write-Host "`nPost-Installation Steps:" -ForegroundColor $BLUE
            Write-Host "• Launch Cursor"
            Write-Host "• Sign Up again using NEW Gmail Account"
            Write-Host "• If there Trial Limit, you can revisit this Terminal and start again"
            Write-Host "`nPress Enter to return to main menu..." -ForegroundColor $GRAY
            $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
        }
        'Q' {
            Clear-Screen
            Write-Host "Thank you for using Cursor AI Reset!" -ForegroundColor $BLUE
            exit
        }
        default {
            Write-Host "`n$($colors.Red)Invalid option. Try again.$($colors.Reset)"
            Start-Sleep -Seconds 2
        }
    }
}

# Start the script
Write-Log "Starting installation process"
Start-MainMenu 