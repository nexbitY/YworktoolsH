@echo off
echo ============================================
echo   Shannon Step 2/3: Import WSL distro
echo ============================================
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\import-distro.ps1"
echo.
pause
