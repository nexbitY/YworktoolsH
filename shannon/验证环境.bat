@echo off
echo ============================================
echo   Shannon environment self-check
echo ============================================
wsl.exe -d shannon-oss -- bash -lc "echo [1] user: $(whoami) && echo [2] Node: $(node --version) && echo [3] Shannon CLI: $(shannon --version) && echo [4] Docker: $(docker --version) && (systemctl is-active --quiet docker && echo [5] Docker daemon: running || echo [5] Docker daemon: NOT running) && echo [6] preloaded images: && docker images --format '     {{.Repository}}:{{.Tag}} ({{.Size}})' && echo [7] API config: && (cat ~/shannon-api.env 2>/dev/null || echo      not configured - run 3-config-api)"
echo.
pause
