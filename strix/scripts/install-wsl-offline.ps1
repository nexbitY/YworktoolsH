# Shannon 离线部署 - WSL2 离线安装（无需联网）
# 适用于干净 Win11 内网机：检测 WSL，缺失则用随包 MSI 离线安装并启用所需 Windows 功能。
$ErrorActionPreference = 'Stop'

function Test-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    (New-Object Security.Principal.WindowsPrincipal $id).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Admin)) {
    Write-Host '[!] 需要管理员权限，正在请求提权...' -ForegroundColor Yellow
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

Write-Host '[1/4] 检测 WSL 是否已安装...'
$wslOk = $false
try {
    $null = & wsl.exe --status 2>&1
    if ($LASTEXITCODE -eq 0) { $wslOk = $true }
} catch { }

if ($wslOk) {
    Write-Host '[OK] WSL 已安装。' -ForegroundColor Green
} else {
    $msi = Join-Path $PSScriptRoot '..\wsl.3.0.5.0.x64.msi'
    if (-not (Test-Path $msi)) { $msi = Join-Path $PSScriptRoot '..\distro\wsl.3.0.5.0.x64.msi' }
    if (-not (Test-Path $msi)) {
        Write-Host "[X] 未找到 WSL 离线安装包 wsl.3.0.5.0.x64.msi，请确认压缩包完整。" -ForegroundColor Red
        exit 1
    }
    Write-Host '[2/4] 启用 Windows 功能（VirtualMachinePlatform / WSL）...'
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart | Out-Null
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart | Out-Null
    Write-Host '[3/4] 静默安装 WSL 3.0.5 离线包（约 1-2 分钟）...'
    $p = Start-Process msiexec.exe -ArgumentList "/i `"$msi`" /qn /norestart" -Wait -PassThru
    if ($p.ExitCode -ne 0) {
        Write-Host "[X] WSL MSI 安装失败（退出码 $($p.ExitCode)）。请重启机器后再运行本脚本重试。" -ForegroundColor Red
        exit 1
    }
    Write-Host '[OK] WSL 安装完成。' -ForegroundColor Green
}

Write-Host '[4/4] 设置默认 WSL 版本为 2...'
& wsl.exe --set-default-version 2 2>&1 | Out-Null

Write-Host ''
Write-Host '=========================================================='
Write-Host ' WSL2 就绪。注意事项：' -ForegroundColor Green
Write-Host '  - 如刚才启用了 Windows 功能，请先重启电脑再执行下一步。'
Write-Host '  - 需要在 BIOS/UEFI 中开启 CPU 虚拟化（VT-x/AMD-V）。'
Write-Host '  - 下一步：运行 2-导入发行版.bat'
Write-Host '=========================================================='
