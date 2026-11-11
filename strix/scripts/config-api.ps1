# Strix 本地 API 配置：生成本包的 strix-env.bat（Windows 原生模式用）
# 同时写入 WSL 发行版 /home/strix/strix-api.env（WSL 模式用）。
$ErrorActionPreference = 'Stop'
$DistName = 'strix-oss'
$PkgRoot  = Split-Path $PSScriptRoot -Parent

function Read-Default($prompt, $def) {
    $v = Read-Host "$prompt [$def]"
    if ([string]::IsNullOrWhiteSpace($v)) { $def } else { $v }
}

Write-Host '本脚本把你的本地大模型 API（OpenAI 兼容：vLLM / LM Studio / one-api 网关等）接入 Strix。'
Write-Host ''
$base  = Read-Default 'API Base URL（例如 http://localhost:8000/v1；Ollama 原生则填 http://localhost:11434）', 'http://localhost:8000/v1'
$model = Read-Default '模型 ID（例如 glm-4.6 / qwen3-235b）', 'glm-4.6'
$key   = Read-Default 'API Key（本地服务若无鉴权可直接回车）', 'local'

if ($base -match '11434/?$' -and $base -notmatch '/v1') {
    $provider = 'ollama'   # Ollama 原生 API：provider 用 ollama/，base 不带 /v1
} else {
    $provider = 'openai'   # 通用 OpenAI 兼容：provider 用 openai/，base 需带 /v1
    if ($provider -eq 'openai' -and $base -notmatch '/v1/?$') { $base = $base.TrimEnd('/') + '/v1' }
}

$envBat = @"
@echo off
rem 由 3-配置本地API.bat 生成 —— Strix 本地 API 环境
set STRIX_LLM=$provider/$model
set LLM_API_KEY=$key
set LLM_API_BASE=$base
"@
[System.IO.File]::WriteAllText((Join-Path $PkgRoot 'strix-env.bat'), $envBat, (New-Object System.Text.UTF8Encoding $false))

# WSL 模式配置（localhost 需替换为 WSL 网关，由 strix-wsl 启动时动态处理）
$wslEnv = @"
# Strix 本地 API 配置（WSL 模式）
STRIX_LLM="$provider/$model"
LLM_API_KEY="$key"
LLM_API_BASE="$base"
"@
$wslEnv | & wsl.exe -d $DistName -u root -- bash -c 'cat > /home/strix/strix-api.env && chown strix:strix /home/strix/strix-api.env && echo WSL侧配置写入成功'

Write-Host ''
Write-Host '=========================================================='
Write-Host " 配置完成！Provider=$provider  模型=$model" -ForegroundColor Green
Write-Host ' 用法示例（在 Windows 终端中）：'
Write-Host '   strix.bat -t D:\代码仓库路径          （本地代码审计/白盒）'
Write-Host '   strix.bat -t http://目标地址           （黑盒 Web 测试）'
Write-Host '   strix.bat -n -t http://目标地址        （无界面模式）'
Write-Host ' 提示：目标应用跑在本机时，-t 里不要用 localhost，'
Write-Host '       strix.bat 启动时会显示"宿主机 IP"，用它替代。'
Write-Host '=========================================================='
