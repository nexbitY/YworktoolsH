#!/usr/bin/env bash
# strix-entry —— 内置在 strix-oss 发行版中的启动入口（WSL 模式）
# 职责：等 docker 就绪 -> 加载 /home/strix/strix-api.env（localhost 自动指向 Windows 宿主机）
#       -> 转换参数里的 Windows 路径 -> exec strix
set -u

if ! docker info >/dev/null 2>&1; then
  sudo -n systemctl start docker >/dev/null 2>&1 || true
fi
i=0
while ! docker info >/dev/null 2>&1; do
  i=$((i+1)); [ $i -gt 30 ] && { echo "[strix-entry] Docker 未就绪，请稍后重试"; exit 1; }
  sleep 2
done

GW=$(ip route show default 2>/dev/null | awk '{print $3; exit}')
[ -n "${GW}" ] && echo "[strix-entry] Windows 宿主机 IP: ${GW}（目标/API 在本机时，请用它代替 localhost）"

ENVF=/home/strix/strix-api.env
if [ -f "$ENVF" ]; then
  . "$ENVF"
  if [ -n "${LLM_API_BASE:-}" ]; then
    LLM_API_BASE=$(printf '%s' "$LLM_API_BASE" | sed "s#\(^http://\)\?\(localhost\|127\.0\.0\.1\)#http://${GW}#")
    export LLM_API_BASE
    echo "[strix-entry] 本地API已启用: ${STRIX_LLM:-} @ ${LLM_API_BASE}"
  fi
fi

ARGS=()
for a in "$@"; do
  case "$a" in
    [A-Za-z]:\\*|[A-Za-z]:/*)
      w=$(wslpath -u "$a" 2>/dev/null) && ARGS+=("$w") || ARGS+=("$a") ;;
    *) ARGS+=("$a") ;;
  esac
done

exec strix "${ARGS[@]}"
