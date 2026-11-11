@echo off
echo ============================================
echo   Strix Step 1/3: Install WSL2 offline
echo ============================================
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\install-wsl-offline.ps1"
echo.
pause
