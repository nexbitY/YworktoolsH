# Shannon 本地 API 配置：把本地大模型 API 写入发行版 /home/shannon/shannon-api.env
# 每次启动 shannon.bat 时会按该配置自动生成 models.json（自动处理 localhost -> WSL 网关 IP）。
$ErrorActionPreference = 'Stop'
$DistName = 'shannon-oss'

function Read-Default($prompt, $def) {
    $v = Read-Host "$prompt [$def]"
    if ([string]::IsNullOrWhiteSpace($v)) { $def } else { $v }
}

Write-Host '本脚本把你的本地大模型 API（OpenAI 兼容，如 vLLM / Ollama / LM Studio / one-api 网关）接入 Shannon。'
Write-Host ''
$base  = Read-Default 'API Base URL（例如 http://localhost:8000/v1 或 http://10.0.0.5:8000/v1）', 'http://localhost:8000/v1'
$model = Read-Default '模型 ID（例如 glm-4.6 / qwen3-235b / deepseek-v4）', 'glm-4.6'
$key   = Read-Default 'API Key（本地服务若无鉴权可直接回车）', 'local'

$envContent = @"
# Shannon 本地 API 配置（由 3-配置本地API.bat 生成）
SHANNON_LOCAL_BASE_URL="$base"
SHANNON_LOCAL_MODEL_ID="$model"
SHANNON_LOCAL_API_KEY="$key"
"@

# 通过 stdin 写入发行版（最稳妥，不依赖 /mnt 路径）
$envContent | & wsl.exe -d $DistName -u root -- bash -c 'cat > /home/shannon/shannon-api.env && chown shannon:shannon /home/shannon/shannon-api.env && echo 写入成功 && cat /home/shannon/shannon-api.env'

Write-Host ''
Write-Host '=========================================================='
Write-Host ' 配置完成！' -ForegroundColor Green
Write-Host ' 用法示例（在 Windows 终端中）：'
Write-Host '   shannon.bat start -u http://目标地址 -r D:\代码仓库路径'
Write-Host ' 注意：'
Write-Host '  - 目标应用和 API 跑在本机 Windows 时，-u 里不要用 localhost，'
Write-Host '    启动 shannon.bat 时屏幕会显示"宿主机 IP"，用它替代 localhost。'
Write-Host '  - 代码仓库放 Windows 盘即可，shannon.bat 会自动转成 /mnt/d/... 路径。'
Write-Host '=========================================================='
