@echo off
<<<<<<< HEAD
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
=======
cd /d "%~dp0"
powershell.exe -ExecutionPolicy Bypass -NoProfile -Command ^
    "Start-Process powershell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%~dp0\scripts\reset.ps1""' -Verb RunAs"
pause
>>>>>>> 28e8a8c164d66a7ec0359f699fdfe83d80ecd2af
