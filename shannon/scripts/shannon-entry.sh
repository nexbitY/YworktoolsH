#!/usr/bin/env bash
# shannon-entry —— 内置在 shannon-oss 发行版中的启动入口
# 职责：等 docker 就绪 -> 依据 /home/shannon/shannon-api.env 生成 models.json
#       -> 转换参数里的 Windows 路径 -> exec shannon
set -u

# 1) Docker 就绪（WSL 启动时 systemd 自动拉起 docker，这里兜底等待最多 60s）
if ! docker info >/dev/null 2>&1; then
  sudo -n systemctl start docker >/dev/null 2>&1 || true
fi
i=0
while ! docker info >/dev/null 2>&1; do
  i=$((i+1)); [ $i -gt 30 ] && { echo "[shannon-entry] Docker 未就绪，请稍后重试或运行: wsl -d shannon-oss -- sudo systemctl start docker"; exit 1; }
  sleep 2
done

# 2) 显示宿主机 IP（容器内访问本机 Windows 上的服务用它，不要用 localhost）
GW=$(ip route show default 2>/dev/null | awk '{print $3; exit}')
[ -n "${GW}" ] && echo "[shannon-entry] Windows 宿主机 IP: ${GW}（目标/API 在本机时，请用它代替 localhost）"

# 3) 生成本地 API 的 models.json
ENVF=/home/shannon/shannon-api.env
if [ -f "$ENVF" ]; then
  . "$ENVF"
  B="${SHANNON_LOCAL_BASE_URL:-}"
  if [ -n "$B" ]; then
    # localhost/127.0.0.1 -> WSL 网关（即 Windows 宿主机），容器内可达
    B=$(printf '%s' "$B" | sed "s#\(^http://\)\?\(localhost\|127\.0\.0\.1\)#http://${GW}#")
    case "$B" in
      */v1|*/v1/) ;;
      *) B="${B%/}/v1" ;;
    esac
    cat > /home/shannon/models.json <<EOF
{
  "providers": {
    "localapi": {
      "baseUrl": "${B}",
      "api": "openai-completions",
      "apiKey": "local",
      "models": [ { "id": "${SHANNON_LOCAL_MODEL_ID}" } ]
    }
  }
}
EOF
    export SHANNON_AI_API_KEY="${SHANNON_LOCAL_API_KEY:-local}"
    export SHANNON_AI_MODEL="localapi:${SHANNON_LOCAL_MODEL_ID}"
    echo "[shannon-entry] 本地API已启用: ${SHANNON_AI_MODEL} @ ${B}"
  fi
fi

# 4) 转换参数中的 Windows 路径（D:\x\y -> /mnt/d/x/y），便于直接复制粘贴
ARGS=()
for a in "$@"; do
  case "$a" in
    [A-Za-z]:\\*|[A-Za-z]:/*)
      w=$(wslpath -u "$a" 2>/dev/null) && ARGS+=("$w") || ARGS+=("$a") ;;
    *) ARGS+=("$a") ;;
  esac
done

# 5) start 命令附加 models-config；其余命令原样透传
if [ "${1:-}" = "start" ] && [ -f /home/shannon/models.json ]; then
  exec shannon "${ARGS[@]}" --models-config /home/shannon/models.json
fi
exec shannon "${ARGS[@]}"
