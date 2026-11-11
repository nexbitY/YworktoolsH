@echo off
echo ============================================
echo   Shannon Step 3/3: Configure local API
echo ============================================
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\config-api.ps1"
echo.
pause
