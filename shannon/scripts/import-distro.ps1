# Shannon 离线部署 - 导入预配置 WSL 发行版 shannon-oss
# 自动合并分卷 tar（若存在），然后 wsl --import，并做启动自检。
$ErrorActionPreference = 'Stop'
$DistName = 'shannon-oss'
$PkgRoot  = Split-Path $PSScriptRoot -Parent
$DistDir  = Join-Path $PkgRoot 'wsl-distro'
$TarDir   = Join-Path $PkgRoot 'distro'
$Tar      = Join-Path $TarDir 'shannon-oss.tar'

# 已存在则询问
$existing = & wsl.exe -l -q 2>$null | ForEach-Object { $_.Trim([char]0) } | Where-Object { $_ -eq $DistName }
if ($existing) {
    Write-Host "[!] 发行版 $DistName 已存在。跳过导入（如需重装请先执行: wsl --unregister $DistName）。" -ForegroundColor Yellow
    exit 0
}

# 合并分卷
if (-not (Test-Path $Tar)) {
    $parts = Get-ChildItem (Join-Path $TarDir 'shannon-oss.tar.part*') -ErrorAction SilentlyContinue | Sort-Object Name
    if ($parts) {
        Write-Host ("[1/3] 发现 {0} 个分卷，正在合并为 shannon-oss.tar（需要约 {1:N1} GB 磁盘空间）..." -f $parts.Count, (($parts | Measure-Object Length -Sum).Sum / 1GB))
        $list = ($parts | ForEach-Object { $_.FullName }) -join '+'
        cmd /c "copy /b `"$list`" `"$Tar`"" | Out-Null
        Write-Host '[OK] 合并完成。'
    } else {
        Write-Host "[X] $TarDir 下既没有 shannon-oss.tar 也没有分卷文件，压缩包不完整。" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host '[1/3] 找到完整 tar，无需合并分卷。'
}

Write-Host "[2/3] 导入发行版到 $DistDir ..."
& wsl.exe --import $DistName $DistDir $Tar
if ($LASTEXITCODE -ne 0) { Write-Host '[X] 导入失败。请确认已安装 WSL2 且已重启。' -ForegroundColor Red; exit 1 }
Write-Host '[OK] 导入完成。' -ForegroundColor Green

Write-Host '[3/3] 启动自检（首次启动 systemd + docker 约需 30-60 秒）...'
Start-Sleep -Seconds 20
& wsl.exe -d $DistName -- bash -lc "systemctl is-active docker >/dev/null 2>&1 || systemctl start docker; sleep 5; echo user=\$(whoami); shannon --version; docker images --format '{{.Repository}}:{{.Tag}}'"
Write-Host ''
Write-Host '=========================================================='
Write-Host ' 导入完成！下一步：' -ForegroundColor Green
Write-Host '  - 运行 3-配置本地API.bat 填入你的本地大模型 API'
Write-Host '  - 之后用 shannon.bat 启动扫描'
Write-Host '=========================================================='
