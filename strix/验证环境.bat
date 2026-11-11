@echo off
echo ============================================
echo   Strix environment self-check
echo ============================================
echo [native exe]
bin\strix-1.7.1-windows-x86_64.exe --version
echo.
echo [Docker engine inside WSL]
wsl.exe -d strix-oss -- bash -lc "echo user: $(whoami) && echo Docker: $(docker --version) && (systemctl is-active --quiet docker && echo Docker daemon: running || echo Docker daemon: NOT running) && echo preloaded images: && docker images --format '     {{.Repository}}:{{.Tag}} ({{.Size}})' && echo WSL strix: $(strix --version) && echo API config: && (cat ~/strix-api.env 2>/dev/null || echo      not configured)"
echo.
echo [TCP 2375 for native mode]
powershell -NoProfile -Command "$t = Test-NetConnection -ComputerName localhost -Port 2375 -WarningAction SilentlyContinue; if ($t.TcpTestSucceeded) { 'localhost:2375 OK' } else { 'localhost:2375 NOT reachable (wake up: wsl -d strix-oss)' }"
echo.
pause
