@echo off
rem Strix launcher - WSL mode (best compatibility fallback)
rem Usage same as strix.bat
wsl.exe -d strix-oss -- /usr/local/bin/strix-entry %*
set EC=%ERRORLEVEL%
exit /b %EC%
