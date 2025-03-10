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
