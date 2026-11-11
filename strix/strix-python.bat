@echo off
rem Strix launcher - pure Python mode (fallback if the single-file exe is blocked by AV)
rem Usage same as strix.bat
setlocal
set DOCKER_HOST=tcp://localhost:2375
wsl.exe -d strix-oss -- /bin/true >nul 2>&1
if exist "%~dp0strix-env.bat" call "%~dp0strix-env.bat"
set PYTHONPATH=%~dp0runtime\python313\site-packages
"%~dp0runtime\python313\python.exe" "%~dp0runtime\run-strix.py" %*
set EC=%ERRORLEVEL%
endlocal & exit /b %EC%
