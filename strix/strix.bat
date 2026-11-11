@echo off
rem Strix launcher - native Windows exe + Docker engine inside WSL distro strix-oss
rem Usage: strix.bat -t D:\repo   /   strix.bat -t http://target   /   strix.bat view
setlocal EnableDelayedExpansion

rem wake up the WSL distro (systemd starts docker automatically)
wsl.exe -d strix-oss -- /bin/true >nul 2>&1

rem resolve the WSL distro IP (WSL NAT address; docker listens on 0.0.0.0:2375 there)
set WSLIP=
for /f %%i in ('wsl.exe -d strix-oss -- bash -lc "ip -4 route get 1 2>/dev/null | head -1 | grep -oP \"src \K[\d.]+\""') do set WSLIP=%%i
if "%WSLIP%"=="" (
    echo [strix.bat] Cannot resolve WSL distro IP. Try: wsl -d strix-oss
    exit /b 1
)
set DOCKER_HOST=tcp://%WSLIP%:2375

rem wait for docker TCP port (max 120s; first boot of the distro can be slow)
powershell -NoProfile -Command "$deadline=(Get-Date).AddSeconds(120); while((Get-Date) -lt $deadline){ $c=New-Object Net.Sockets.TcpClient; try{ $c.Connect('%WSLIP%',2375); $c.Close(); exit 0 }catch{ $c.Close() }; Start-Sleep -Seconds 3 }; exit 1" >nul 2>&1
if %ERRORLEVEL%==0 goto ready
echo [strix.bat] Docker engine not ready at %WSLIP%:2375. Try: wsl -d strix-oss
echo [strix.bat] Or use WSL mode instead: strix-wsl.bat
exit /b 1
:ready

rem print host hints
for /f %%i in ('wsl.exe -d strix-oss -- bash -lc "ip route show default 2>/dev/null | cut -d \" \" -f3"') do echo [strix.bat] Windows host IP: %%i ^(use it instead of localhost for local targets^)
echo [strix.bat] Docker engine: %DOCKER_HOST%

rem load local LLM API config
if exist "%~dp0strix-env.bat" call "%~dp0strix-env.bat"

"%~dp0bin\strix-1.7.1-windows-x86_64.exe" %*
set EC=%ERRORLEVEL%
endlocal & exit /b %EC%
