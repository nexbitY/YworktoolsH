#!/usr/bin/env bash
# FOFA 三账号 helper（Linux/bash 版，主号 → backup → backup2，限流切下一个）
# 凭据从同目录 .env 读取（FOFA_EMAIL/FOFA_KEY、*_BACKUP、*_BACKUP2）。
# 用途：MCP 未重启/未热加载时 Agent 的 curl 手动备用。用法：
#   ./fofa_dual.sh 'domain="example.com"' [size] [fields]

set -u
cd "$(dirname "$0")"
# 手动解析 .env（不依赖 dotenv）
set -a; [ -f .env ] && . ./.env; set +a

QUERY="${1:?usage: fofa_dual.sh 'fofa查询语句' [size] [fields]}"
SIZE="${2:-100}"
FIELDS="${3:-host,ip,port,title,server}"
Q64=$(printf '%s' "$QUERY" | base64 -w0)

try_account() {  # label email key
  local label="$1" email="$2" key="$3" uri
  [ -z "$key" ] && return 1
  if [ -n "$email" ]; then
    uri="https://fofa.info/api/v1/search/all?email=${email}&key=${key}&qbase64=${Q64}&size=${SIZE}&fields=${FIELDS}"
  else
    uri="https://fofa.info/api/v1/search/all?key=${key}&qbase64=${Q64}&size=${SIZE}&fields=${FIELDS}"
  fi
  local body
  body=$(wget -qO- --timeout=30 "$uri") || return 1
  if printf '%s' "$body" | grep -qE '"error":\s*true'; then
    if printf '%s' "$body" | grep -qE '820041|频繁|上限|F点'; then
      echo "[fofa_dual] $label 限流，切下一个" >&2
      return 1
    fi
    echo "[fofa_dual] $label 出错: $body" >&2
    return 1
  fi
  echo "[fofa_dual] 命中账号: $label" >&2
  printf '%s\n' "$body"
}

for spec in "primary:${FOFA_EMAIL}:${FOFA_KEY}" \
            "backup:${FOFA_EMAIL_BACKUP}:${FOFA_KEY_BACKUP}" \
            "backup2:${FOFA_EMAIL_BACKUP2}:${FOFA_KEY_BACKUP2}"; do
  label="${spec%%:*}"; rest="${spec#*:}"
  email="${rest%%:*}"; key="${rest#*:}"
  if out=$(try_account "$label" "$email" "$key"); then
    printf '%s\n' "$out"
    exit 0
  fi
done
echo "[fofa_dual] 三账号全部失败/限流：停 FOFA，挖已入库" >&2
exit 1
