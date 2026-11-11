# Shannon 离线内网部署包（Win11 完整可移植版）

> 项目主页：https://github.com/KeygraphHQ/shannon （AGPL-3.0，51000+ stars）
> 本包版本：Shannon CLI 3.5.0 / Node.js 22.23.4 / Docker CE 29.x / Ubuntu 24.04 WSL2 发行版（预装 keygraph/shannon:3.5.0 + temporalio/temporal:1.7.0 镜像）
> 打包日期：2026-11-11

Shannon 是 Keygraph 开源的自主 AI 渗透测试 agent：分析 Web 应用源码 → 识别攻击路径 → 真实利用验证 → 只报告"可复现利用"的漏洞（No exploit, no report）。适用于 Web 应用与 API 的白盒+黑盒混合测试。

本包为**完全离线可移植版本**：内网干净 Win11 机器无需任何互联网连接即可安装运行，模型流量直连你指定的**本地 API**（OpenAI 兼容：vLLM / Ollama / LM Studio / one-api / new-api 网关等），全程不出内网。

---

## ⚠️ 授权与安全须知

- **只能对你拥有或已获书面授权的系统使用**（你们自己的 Web 应用/SaaS 系统、测试环境）。
- Shannon 会真实执行漏洞利用（建用户、提交表单、改变应用状态、触发外连）。请对测试/预发环境使用，不要打生产。
- 本包内 Docker 引擎仅监听 WSL 内部与本机回环，不对内网其他机器暴露。

---

## 包内容

```
shannon/
├── 1-安装WSL离线.bat        # 第1步：WSL2 离线安装（含随包 MSI，需管理员）
├── 2-导入发行版.bat          # 第2步：导入预配置发行版 shannon-oss（自动合并分卷）
├── 3-配置本地API.bat         # 第3步：写入你的本地大模型 API 地址/模型/密钥
├── shannon.bat               # 日常启动器（等于在 WSL 里跑 shannon 命令）
├── 验证环境.bat               # 自检：CLI/Docker/镜像/API 配置
├── wsl.3.0.5.0.x64.msi       # WSL 3.0.5 离线安装包
├── distro/                   # shannon-oss.tar 或其分卷（shannon-oss.tar.part00...）
├── scripts/                  # 上述 bat 的 PowerShell 实现与发行版内 entry 脚本
└── docs/                     # 本手册 + 上游文档
```

## 部署三步

1. **`1-安装WSL离线.bat`**（右键管理员运行）
   - 已装 WSL2 则直接通过；否则用包内 MSI 静默安装并启用所需 Windows 功能（可能要求重启）。
   - 前提：BIOS 已开虚拟化（VT-x / AMD-V）。
2. **`2-导入发行版.bat`**
   - 自动合并分卷（若有）→ `wsl --import shannon-oss` → 启动自检。
   - 发行版内已装好：Ubuntu 24.04 + systemd + Docker CE + docker-compose-plugin + Node 22 + Shannon CLI 3.5.0 + 两个 Docker 镜像。**无需联网。**
3. **`3-配置本地API.bat`**
   - 按提示填：API Base URL（如 `http://localhost:8000/v1`）、模型 ID（如 `glm-4.6`）、API Key（可空）。
   - 配置存在 WSL 内 `~/shannon-api.env`，之后每次 `shannon.bat` 启动会自动生成 models.json（自动把 localhost 换成容器可达的宿主机地址）。

## 日常使用

```bat
:: 对一个有源码的 Web 目标发起渗透测试（白盒模式，效果最好）
shannon.bat start -u http://192.168.1.50:8080 -r D:\code\your-webapp

:: 交互式向导 / 查看帮助 / 恢复中断的扫描
shannon.bat setup
shannon.bat --help
shannon.bat resume

:: 直接进 WSL 终端手动操作
wsl -d shannon-oss
```

### 关键注意事项（重要）

| 场景 | 怎么填 |
|---|---|
| 目标应用 / API 跑在**本机 Windows** | 不要写 `localhost`。`shannon.bat` 每次启动会打印「Windows 宿主机 IP」（形如 172.x.x.x），用它替代 localhost |
| 目标 / API 在**内网其他机器** | 直接写内网 IP/主机名，无需改动 |
| 代码仓库路径 | 直接写 Windows 路径（`D:\code\xxx`），启动器自动转成 WSL 路径 |
| 扫描结果 | 在 WSL 内 `~/shannon-workspaces/`，也可从 Windows 资源管理器 `\\wsl$\shannon-oss\home\shannon\` 直接拷出（PDF/Markdown/SARIF/JSON 报告） |

- 模型要求：Shannon 全程多轮工具调用，**模型必须支持稳定 tool-use**。推荐 GLM-4.6 及以上、Qwen3-235B、DeepSeek-V4 等强模型；弱模型会显著降低检出质量。
- 一次完整扫描约 1~1.5 小时（取决于模型速度与应用复杂度）。
- Temporal Web UI：扫描启动后可访问 `http://<宿主机IP>:8233`（WSL 端口自动转发）。

## 环境自检

任何时候可运行 `验证环境.bat`：逐项检查用户/Node/Shannon CLI/Docker 守护进程/预置镜像/API 配置。

## 卸载

```bat
wsl --unregister shannon-oss
```
然后删除本文件夹即可，系统无残留。

## 常见问题

- **"Docker must be installed and running"**：发行版没起来。先 `wsl -d shannon-oss` 进去执行 `sudo systemctl start docker`（正常情况 systemd 自启）。
- **模型预检失败（provider/model 不识别）**：说明没走本地 API 配置。确认已运行过 `3-配置本地API.bat`，并用 `shannon.bat start ...`（而非直接进 WSL 跑裸命令）。
- **API 连不通**：目标 API 若在本机 Windows，确认监听地址是 `0.0.0.0` 而非仅 `127.0.0.1`（否则 WSL 网关访问不到）；防火墙放行该端口。
- **杀软告警**：Shannon 的报告/exploit 代码会被 Windows Defender 误报，把本目录与 `wsl-distro` 目录加入白名单。
- **想换模型/网关**：重跑 `3-配置本地API.bat` 即可。

## 上游致谢

- Shannon by Keygraph — https://github.com/KeygraphHQ/shannon （AGPL-3.0）
- 本包只是把上游官方发行物（npm 包 + Docker Hub 镜像）预先下载并离线化打包，未修改其代码。
