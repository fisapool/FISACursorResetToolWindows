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