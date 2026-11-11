@echo off
rem Shannon launcher - runs the shannon CLI inside the preconfigured WSL distro
rem Usage: shannon.bat start -u http://target -r D:\repo
rem        shannon.bat setup / --help / clean ...
wsl.exe -d shannon-oss -- /usr/local/bin/shannon-entry %*
set EC=%ERRORLEVEL%
exit /b %EC%
