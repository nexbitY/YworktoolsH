# Strix 离线内网部署包（Win11 完整可移植版）

> 项目主页：https://github.com/usestrix/strix （Apache-2.0，74000+ stars）
> 本包版本：Strix 1.7.1（Windows 原生 exe + WSL Linux 二进制 + 纯 Python 运行时三通道）/ Docker CE 29.x + 沙箱镜像 ghcr.io/usestrix/strix-sandbox:1.4.1 预载 / Ubuntu 24.04 WSL2
> 打包日期：2026-11-11

Strix 是开源的多 agent AI 渗透测试工具：像真实黑客一样动态运行你的代码、找漏洞、用可复现 PoC 验证，支持自动生成修复补丁与合规报告。支持：
- 本地代码审计（白盒）：`-t D:\repo`
- 黑盒 Web 测试：`-t http://target`
- API 测试（OpenAPI/Swagger/Postman）
- 认证态灰盒测试、多目标、CI 无人值守模式（`-n`）

本包为**完全离线可移植版本**：内网干净 Win11 无需互联网即可安装运行，模型流量直连你的**本地 API**（OpenAI 兼容），全程不出内网。

---

## ⚠️ 授权与安全须知

- **只能对你拥有或已获书面授权的系统使用**。Strix 会对目标真实发起攻击测试。
- 沙箱容器带完整渗透工具链（Kali 系），请妥善保管本包。

---

## 包内容与三种运行模式

| 模式 | 启动器 | 说明 |
|---|---|---|
| **A. Windows 原生**（推荐） | `strix.bat` | 官方单文件 exe，体验最好。Docker 引擎在 WSL 发行版内，经 `localhost:2375` 连接 |
| **B. WSL 内运行** | `strix-wsl.bat` | 官方 Linux 二进制在 WSL 里跑，兼容性最稳（exe 被杀软拦截时用） |
| **C. 纯 Python** | `strix-python.bat` | 嵌入式 Python 3.13 + 官方 wheel 预装依赖，代码完全可见可审计，杀软误报时的终极后备 |

三种模式功能完全一致，配置共用（`3-配置本地API.bat` 一次配置三处生效）。

```
strix/
├── 1-安装WSL离线.bat / 2-导入发行版.bat / 3-配置本地API.bat   # 部署三步
├── strix.bat / strix-wsl.bat / strix-python.bat               # 三种模式启动器
├── 验证环境.bat                                                # 自检（exe/Docker/镜像/端口/API）
├── wsl.3.0.5.0.x64.msi                                        # WSL 离线安装包
├── bin\strix-1.7.1-windows-x86_64.exe                         # 官方 Windows 独立二进制
├── runtime\python313\                                          # 嵌入式 Python + 全部依赖预装
├── wheels\strix_agent-1.7.1-py3-none-win_amd64.whl            # 官方 wheel 留档
├── distro\                                                     # strix-oss.tar 或其分卷
├── scripts\                                                    # PowerShell 脚本 + WSL entry
└── docs\                                                       # 本手册 + 上游文档
```

## 部署三步

1. **`1-安装WSL离线.bat`**（管理员）——装 WSL2（含随包 MSI，可能要求重启；BIOS 需开虚拟化）。
2. **`2-导入发行版.bat`**——导入 `strix-oss` 发行版（Ubuntu 24.04 + Docker CE + 预载沙箱镜像 + TCP 2375 监听），自动自检。
3. **`3-配置本地API.bat`**——填本地 API 地址 / 模型 ID / Key。Ollama 原生地址（:11434）会自动识别为 `ollama/` 前缀；其他 OpenAI 兼容地址自动用 `openai/` 前缀并补 `/v1`。

## 日常使用

```bat
:: 白盒：审计本地代码仓库（桌面客户端逆向出的源码放这里）
strix.bat -t D:\code\desktop-app-source

:: 黑盒：测试 Web 应用 / SaaS 系统
strix.bat -t http://192.168.1.50:8080

:: 认证态灰盒 + 无人值守模式（CI/计划任务）
strix.bat -n -t http://192.168.1.50:8080 --instruction "使用账号 user/pass 登录后测试"

:: API 契约测试
strix.bat -t D:\api\openapi.yaml -t http://192.168.1.50:8080

:: 查看本地结果面板（findings/agent 地图/历史 run）
strix.bat view
```

结果输出在运行目录的 `strix_runs\<run-name>\`。

### 关键注意事项（重要）

- **目标跑在本机 Windows 时不要用 `localhost`**：启动器会打印「Windows 宿主机 IP」（形如 172.x.x.x），用它。
- 模型必须支持稳定 **tool-use / function calling**（vLLM 需 `--enable-auto-tool-choice --tool-call-parser ...`；Ollama 模型建议关 thinking、调大 num_ctx）。
- exe 首次运行若被 360/火绒拦截：加白名单，或直接用 `strix-wsl.bat` / `strix-python.bat`。
- Docker 引擎监听 `tcp://0.0.0.0:2375`（仅 WSL 内）——Windows 侧通过 `localhost:2375` 访问；如内网有其他机器能直达本机 2375 端口，请用 Windows 防火墙屏蔽入站。

## 环境自检

`验证环境.bat`：exe 版本 / WSL 内 Docker / 预载镜像 / 2375 连通性 / API 配置，一次全查。

## 卸载

```bat
wsl --unregister strix-oss
```
删除本文件夹即可。

## 上游致谢

- Strix by usestrix — https://github.com/usestrix/strix （Apache-2.0）
- 本包仅将上游官方发行物（GitHub Release 二进制/wheel + GHCR 镜像）预下载离线化，未修改其代码。
