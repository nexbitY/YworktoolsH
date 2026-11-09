# YworktoolsH

> 开发 / AI Agent / 安全研究 —— 双系统（**Windows 11 + Ubuntu 24.04 LTS**）环境部署手册与资料备份。
> 全部信息于 **2026-11** 调研核实；版本号与免费政策随时间变化，使用前请以各官方页面为准。

## 目录

1. [仓库内容说明](#仓库内容说明)
2. [匿名邮箱清单](#匿名邮箱清单)
3. [AI Agent 工具安装指南](#ai-agent-工具安装指南)
4. [免费大模型 Token 调研](#免费大模型-token-调研)
5. [新系统必装软件清单](#新系统必装软件清单)
6. [内网白盒审计与渗透漏挖工具库](#内网白盒审计与渗透漏挖工具库)
7. [声明](#声明)

---

## 仓库内容说明

```
files/
├── claude/           # Claude Code 安全研究工作流（rules 规则 / skills 知识库 / MCP 服务源码）
│                     #   - rules/        ：挖洞流程、报告格式、白盒审计等永久规则
│                     #   - skills/       ：clown-src-skill 漏洞测试知识库（各类漏洞测试方法）
│                     #   - mcp-servers/  ：fofa_MCP（FOFA 资产查询多账号轮换）、playwright 浏览器自动化
│                     #   - CLAUDE.md     ：全局 Agent 规则
│                     #   已剔除 .venv / node_modules 等第三方依赖目录，仅需重装依赖即可使用
├── 北山AI.rar        # AI 自动化挖洞技能仓库备份（学习资料，原样打包）
└── 北山SRC文档.zip   # SRC 漏洞挖掘技巧文档集（学习资料，原样打包）
```

- `claude/` 使用方式：复制到用户目录（如 `~/.claude/`）后，`mcp-servers/fofa_MCP` 执行 `uv sync` 安装依赖，`.env.example` 复制为 `.env` 并填入自己的 FOFA key；`playwright-mcp-local` 执行 `npm install`。
- 两个压缩包为学习资料备份，仅供个人学习，如有侵权请联系删除。

---

## 匿名邮箱清单

适用于注册 GitHub、各类 AI 应用等，**无需实名、无需手机号**（截至 2026-11，国内邮箱 QQ/163/126 等全部强制手机号实名，故以下均为境外服务）。

| 服务 | 费用 | 注册要求 | 能否注册 GitHub / AI 应用 | 备注 |
|---|---|---|---|---|
| **Proton Mail**（proton.me） | 免费 1GB | 无需手机号；新注册有一步人机验证（可用任意邮箱收验证码，官方称不保存关联） | ✅ 接受度最高 | 瑞士，端到端加密，综合首选；大陆需代理 |
| **Tuta**（tuta.com，原 Tutanota） | 免费 1GB | 完全零验证，仅用户名+密码，注册最匿名 | ⚠️ 基本可以 | 德国，加密；`tuta.io` 域名曾被 GitHub 拉黑（可联系 GitHub 支持解封），选 `tuta.com` 域名更稳；大陆需代理 |
| **Mailfence**（mailfence.com） | 免费 500MB | 无需手机号 | ✅ | 比利时，老牌加密邮箱 |
| **Disroot**（disroot.org） | 免费 | 无需手机号，注册时填一句用途说明（防滥用，一般秒过） | ⚠️ 偶尔被小众服务误判 | 开源公益项目 |
| **GMX / mail.com** | 免费 | 多数地区无需手机号 | ✅ | 大陆直连偶尔可行但不稳；商业邮箱隐私性一般，胜在域名不进黑名单 |
| **QRYPTY Mail**（qrypty.com） | 免费 | 约 10 秒注册，无需手机号/密码/个人信息，凭 32 位访问码登录 | ⚠️ 域名较新，部分服务可能拒收 | 自称零日志、部分加密；独立第三方评测少（好评多来自其官网博客），**建议只用于不重要的一次性注册**，重要账号用 Proton/Tuta |

**使用要点：**

- **GitHub 的坑**：GitHub 会主动拦截"疑似一次性"邮箱域名（连 `pm.me`、`tuta.io` 都上过黑名单）。注册 GitHub 用 `proton.me` 主域名最稳；被误拒可联系 GitHub 支持解封。
- **一次性临时邮箱**（Temp Mail、Guerrilla Mail、AdGuard 临时邮箱等）**注册不了 GitHub 和主流 AI 应用**（域名在黑名单），只适合领不重要的一次性验证码。
- **最稳进阶方案**：买一个自己的域名（如通过 Njalla，支持加密货币付款）+ Cloudflare Email Routing（免费）转发到主邮箱。自定义域名不在任何黑名单，可生成无限别名。
- **AI 应用额外门槛**：部分 AI 服务（如 ChatGPT）在邮箱之外还要求手机号验证，注册前先确认流程。
- **大陆访问**：Proton/Tuta/Gmail 均被墙需代理；匿名邮箱用于保护隐私完全合法，但勿用于批量注册（会触发风控封号并可能违反服务条款）。

---

## AI Agent 工具安装指南

以下工具均给出 **Windows 11** 与 **Ubuntu 24.04** 两种安装方式（两系统相同时注明"通用"）。版本截至 2026-11。

### 1. DeepSeek Harness（DSH）— DeepSeek 官方开源插件式 agent harness

- 链接：<https://github.com/deepseek-ai/deepseek-harness> ｜ 文档：<https://deepseek-harness.github.io>
- 当前版本：npm 包 `@deepseek-ai/dsh` **0.1.5-rc.1**（developer preview），需 Node ≥ 18
- 安装（通用）：`npx @deepseek-ai/dsh web`（Web GUI 方式启动）
- 使用：在 platform.deepseek.com 申请 API Key（邮箱/Google 登录，无需手机号），设 `DEEPSEEK_API_KEY` 环境变量或写入 `.env`，或在 Web UI 的 Providers/Models 页填写
- 免费情况：开源免费，模型调用按 DeepSeek API 计费（新户送 500 万 tokens，见[免费 Token 章节](#免费大模型-token-调研)）

### 2. dsh-purge — DSH 社区"破甲"插件（宿主补丁 + 自检 + 提示词管理）

- 链接：<https://github.com/kingcharleslzy-ai/dsh-purge>（Purge Community，当前 **1.6.85**，适配 DSH 0.2.x）
- 安装（三选一，通用）：
  1. DSH 自定义插件市场添加索引 `https://kingcharleslzy-ai.github.io/dsh-purge/index.json`
  2. `dsh plugin --profile web add <release 页面的 .tgz>`
  3. 脚本安装：
     - Ubuntu：`curl -fSL <release>/scripts/install.sh -o install.sh && sh install.sh --dry-run` 确认后去掉 `--dry-run`
     - Win11 PowerShell：下载 `scripts/install.ps1` 后 `powershell -ExecutionPolicy Bypass -File install.ps1 -DryRun` 再正式执行
- 使用：`purge-community selfcheck / status / diagnose / probe / preset / backup` 等子命令；**务必先 dry-run**，仅限自有/授权环境使用

### 3. Verdent（国际版）— 多并行自主 coding agent 套件（BYOK）

- 链接：<https://www.verdent.ai>（GitHub 仓库【未核实】）
- 安装（通用）：VS Code 扩展市场搜 "Verdent"，或 `code --install-extension verdentai.verdent`；另有 JetBrains 支持
- 使用：装扩展 → 登录 → 选 Plan Mode 或直接下任务；BYOK 模式填自己的模型 key
- 免费/价格：$20/$60/$180 月；7 天试用送 200 credits；**BYOK 免费**（用自己 key 不花钱）

### 4. Devin（Cognition）— 云端自主 AI 软件工程师

- 链接：<https://devin.ai> ｜ 注册：<https://app.devin.ai/signup>
- 安装：无需本地安装，云端运行（浏览器 / Slack / GitHub App）
- 使用：GitHub / Google / ChatGPT / 邮箱任一注册（未发现强制手机号）→ 直接建任务
- 免费/价格：Free 档含少量 ACU credits；Pro $20/月、Max $200/月，超额按 ACU 计费

### 5. WorkBuddy（国际版）— 腾讯 AI Agent 办公工作站

- 链接：国际版 <https://www.workbuddy.ai> ｜ 国内版 <https://www.workbuddy.cn> ｜ Windows 安装指南见国内版文档站
- 安装：Win11 官网"立即下载"exe 安装；Ubuntu：未见 Linux 客户端【未核实】
- 使用：装客户端 → 登录 → 一句话派任务；编码功能由 WorkBuddy IDE（原 CodeBuddy）承担
- 免费/价格：推广期基础免费（附试用权益）
- 注：Claude Code 生态另有一个同名开源个人 agent 框架 `KadenMc/work-buddy`，两者无关，勿混淆

### 6. Claude Code — Anthropic 官方 CLI agent

- 链接：<https://code.claude.com> ｜ <https://github.com/anthropic-ai/claude-code>
- 当前版本：**~2.1.x**（迭代快，装最新即可）
- 安装：
  - Win11：`irm https://claude.ai/install.ps1 | iex`（或 `winget install Anthropic.ClaudeCode`）
  - Ubuntu：`curl -fsSL https://claude.ai/install.sh | bash`
  - 通用（Node ≥ 22）：`npm i -g @anthropic-ai/claude-code`
- 使用：项目目录内运行 `claude`，`/login` 用 Claude 账号登录，或设 `ANTHROPIC_API_KEY`；第三方/中转接入用官方网关变量 `CLAUDE_CODE_GATEWAY_URL`（LLM gateway）
- 免费/价格：无免费套餐；Pro $20/月、Max $100/$200/月，或 API 按量

### 7. OpenCode（sst）— 开源终端/桌面 coding agent

- 链接：<https://opencode.ai> ｜ <https://github.com/sst/opencode>
- 安装：
  - Win11：`winget install sst.opencode`（或 PowerShell `irm https://opencode.ai/install.ps1 | iex`）
  - Ubuntu：`curl -fsSL https://opencode.ai/install | bash`
- 使用：`opencode` 启动，`/login` 连接 Zen 或 `/connect` 绑定 provider，`/models` 选模型
- 提供商：Anthropic / OpenAI / Google / Groq / Ollama / OpenRouter 等 200+
- 免费/价格：开源免费；Zen 有免费模型档，其余按各 provider 计费

### 8. ZCode — 智谱 z.ai 官方 GLM coding agent harness

- 链接：<https://zcode.z.ai> ｜ <https://github.com/zai-org/ZCode>（Apache-2.0）
- 当前版本：**3.17.2**
- 安装：
  - Win11：官网下载 `ZCode-3.17.2-win-x64.exe` 桌面版
  - Ubuntu：官网 AppImage / deb / rpm
  - CLI（通用，Node ≥ 22.19）：`npm i -g zcode-app-cli@latest` → 运行 `zcode`
- 使用：首次启动初始化，绑定 Z.ai / BigModel 账号或 GLM Coding Plan；模型：GLM-5.3 / GLM-5.3-Flash / GLM-5-turbo
- 免费/价格：新用户 5 天试用（每日合计 500 万 tokens），之后随 GLM Coding Plan 订阅

### 9. Magpie — 开源模型路由器（给各 agent 统一切换模型）

- 链接：<https://github.com/yetone/magpie> ｜ <https://usemagpie.ai>（MIT）
- 安装（通用）：`curl -fsSL https://usemagpie.ai/install.sh | sh`，或官网下载（macOS/Windows/Linux 托盘应用）
- 使用：添加 provider/订阅账号，自动读取 Claude Code、Codex 等已登录凭证，本地网关统一路由，配额耗尽自动轮换
- 免费/价格：开源免费，模型费用取决于自己的 key/订阅

### 10. MoLi — 面向 AI agent 的无头浏览器

- 链接：<https://github.com/lexmount/moli>（Rust 单文件，中文文档）
- 定位【注意】：**不是** Claude Code 类 CLI agent，而是给 Claude Code 等 agent 用的网页抓取/JS 执行（CDP）工具，可部署在小 VPS
- 安装（通用）：Releases 下载单二进制直接运行
- 未找到名为 "MoLi" 的 Claude Code 类中文 agent【未核实】

### 11. Vibex — 开源 agent-native 工作台（类 Claude Code Desktop + Codex + DSH）

- 链接：<https://github.com/vibex-ai/vibex>（AGPL-3.0，当前 **0.1.0-rc.10**）
- 安装：
  - Win11：Releases 页下载 NSIS exe（未签名需过 SmartScreen）
  - Ubuntu：Releases 页 .deb / AppImage，或 AUR `vibex-bin`
  - 源码构建需 Node 22 + pnpm + Rust
- 使用：Config Center → Agents 添加 Claude Code / Codex 等 → 配 Provider key → 开会话；支持本地网关做多协议转换
- 免费/价格：开源免费

### 12. Matt Pocock 的 AI/Agent 学习资源

- 链接：<https://github.com/mattpocock/skills> ｜ <https://mattpocock.com> ｜ <https://github.com/mattpocock/dictionary-of-ai-coding> ｜ Claude 市场：`claude.com/marketplace/plugins/mattpocock-skills`
- 内容：`skills` 仓库 "Skills for Real Engineers" —— 21+ 个可组合工程纪律 skill（v1.3 起 `/pr`、`/implement-spec`、`/retro`），setup skill 可同时生成 AGENTS.md / CLAUDE.md
- 注："ai-expert-prompts" 仓库与 "AI Expert Watershed" 提示词均未找到可靠来源【未核实】，疑为误传

> DSH 与 dsh-purge 均处快速迭代期，安装前查看各自仓库最新 Release。

---

## 免费大模型 Token 调研

**筛选条件：只用匿名/隐私邮箱（Proton/Tuta 等）注册即可领取，不需手机号、不需实名、不需绑卡。**（截至 2026-11）

### 一、仅邮箱可领

| 平台 | 注册方式 | 免费额度 | 模型 | 有效期 |
|---|---|---|---|---|
| **z.ai**（智谱国际版） | 仅邮箱 | GLM Coding Plan 新户试用约 500~800 万 tokens/天 × 5 天（已转积分制【待核实】）；API 无长期免费层 | GLM-5.2 / 4.6 及更新（GLM-5.3【待核实】） | 5 天 |
| **DeepSeek** platform.deepseek.com | 海外区仅邮箱 | 一次性 **500 万 tokens** | DeepSeek 全系 | 一次性 |
| **Google AI Studio** | Google 账号（多数地区可不绑手机） | Flash 约 150~250 请求/天，Pro 约 250/天；Gemini CLI 250/天 | Gemini 3.x Pro/Flash | 长期（数据用于训练） |
| **Groq** | 仅邮箱 | 约 30 RPM / 1000 请求/天 / 20 万 tokens/天（按模型独立计可轮换） | GPT-OSS-120B、Qwen3、Kimi K2、Llama | 长期 |
| **OpenRouter** | 仅邮箱 | `:free` 模型 20 RPM、50 请求/天（曾充值 $10 → 1000/天） | DeepSeek R1、Qwen、GLM、Kimi 等免费变体 | 长期 |
| **Mistral La Plateforme** | 邮箱（激活免费层曾需手机验证【待核实】） | Experiment 层约 1 请求/秒、2000/天【待核实】 | Mistral 全系含 Codestral | 长期（低优先级） |
| **GitHub Copilot Free** | GitHub 账号（仅邮箱） | 2000 补全/月 + 少量 chat/agent；2026-6 起改 AI credits 计费 | GPT-5 mini、Claude Haiku 4 级入门模型 | 长期 |
| **NVIDIA NIM**（build.nvidia.com） | 仅邮箱 | 1000 credits、40 RPM（论坛可申请提额） | 100+ 开源模型（DeepSeek/Qwen/Llama） | 用完即止 |
| **Cloudflare Workers AI** | 邮箱（CF 账号） | 1 万 neurons/天（UTC 重置，全模型共享） | 50+：Llama、Qwen、DeepSeek、Gemma | 长期 |
| **阿里云 Model Studio 国际版** | 仅邮箱 | 新户每 Qwen 模型约 100 万 tokens（合计可达数千万） | Qwen3.x 全尺寸、部分 DeepSeek/GLM | 90 天 |
| **腾讯云国际 TokenHub** | 邮箱（腾讯云国际账号） | 新户 100 万 tokens | Hunyuan（hy4【待核实】）、DeepSeek、GLM、Kimi | 90 天 |
| **SiliconFlow 国际版** | 仅邮箱 | 送 $1 + 部分永久免费模型（Qwen3-8B、R1-Distill） | 200+ 模型 | 送额用完止 |
| **SambaNova Cloud** | 仅邮箱 | 免费层（历史 $5 credit【额度待核实】） | Llama、Qwen、DeepSeek | 【待核实】 |
| **NanoGPT** | **无需注册**即可试免费模型 | 免费模型每日额度【待核实】，支持加密支付 | DeepSeek/Llama/Qwen 等 | 长期 |
| **Cursor Free** | 仅邮箱 | 2000 补全 + 50 慢速 premium 请求/月（可用 Claude/GPT） | Claude、GPT、Gemini | 长期 |
| **Trae 国际版** | 仅邮箱 | 免费层含 Claude/GPT/Gemini（新模型渐转付费【请求量待核实】） | Claude、GPT、Gemini | 长期 |
| 新渠道 | Google **Antigravity CLI** 免费用 Gemini 3.1 Flash / Claude Sonnet / GPT【待核实】；**Requesty** 200 免费/天【待核实】 | | | |

### 二、需要手机号/绑卡/实名（不符合匿名条件，仅列出备查）

- **bigmodel.cn（智谱国内版）**：手机号注册+实名；新户 2000 万 tokens，GLM-4-Flash 永久免费——额度最大但要实名
- **Anthropic Console**：$5 试用，需短信验证
- **OpenAI**：建 API key 需手机验证，自动免费 credit 基本取消
- **Cerebras**：2026-7 起旧免费层（100 万 tokens/天）废止，改 $5 试用且需绑卡
- **Together AI**（无免费试用）、**Hyperbolic**（免费 credit 已结束）、**Baseten**（仅特定开源模型免费【待核实】）
- **GitHub Models**：2026-7-30 已退役（被 Azure AI Foundry / 用量计费 Copilot 取代）

**备注**：各平台常屏蔽一次性邮箱域名，Proton/Tuta 一般可用；免费层请求数据多用于模型训练；带【待核实】处以官方文档为准。

---

## 新系统必装软件清单

适用于 **Windows 11 虚拟机 + Ubuntu 24.04 LTS 虚拟机（VMware）** 的全新系统。用途：编程开发、查资料、安全研究（合法授权场景）、运行 AI agent。版本截至 2026-11。

### 一、两系统通用（基础开发栈）

| 软件 | 当前版本 | 用途 | 安装 |
|---|---|---|---|
| **Node.js** | 26 LTS "Lithium"（26.13.0；24 为维护线） | JS 运行时（agent CLI 几乎都要） | Win：`winget install Schniz.fnm` → `fnm install --lts`；Ubuntu：`curl -fsSL https://fnm.vercel.app/install \| bash && fnm install --lts` |
| **Python** | 3.14 稳定线（3.14.10；3.15 刚发布，保守选 3.14） | 脚本/AI 生态 | Win：`winget install CondaForge.Miniforge3 astral-sh.uv`；Ubuntu：官网下载 Miniforge sh 安装 + `curl -LsSf https://astral.sh/uv/install.sh \| sh` |
| **Java** | Temurin **JDK 25 LTS**（25.0.5+8） | Burp/Ghidra/开发 | Win：`winget install EclipseAdoptium.Temurin.25.JDK`；Ubuntu：加 adoptium.net apt 源后 `sudo apt install temurin-25-jdk` |
| **Go** | 1.27.3 | 装 ProjectDiscovery 安全工具链必需 | Win：`winget install GoLang.Go`；Ubuntu：`sudo snap install go --classic` |
| **Git / gh** | Git 2.56.0 / gh 2.98.0 | 版本控制 / GitHub 操作 | Win：`winget install Git.Git GitHub.cli`；Ubuntu：`sudo apt install git` + gh 官方 apt 源（cli.github.com） |
| **VS Code** | 1.145 | 主编辑器 | Win：`winget install Microsoft.VisualStudioCode`；Ubuntu：`sudo snap install code --classic`。**关闭遥测**：settings.json 设 `"telemetry.telemetryLevel": "off"`；更彻底用 [VSCodium](https://vscodium.com)（无微软遥测） |
| **Docker** | Desktop 4.98 / Engine v29 | 容器 | Win：`winget install Docker.DockerDesktop`（**VMware 前提**：VM 设置→CPU→勾选虚拟化 Intel VT-x/EPT 开嵌套虚拟化，内存 ≥8G；重度用容器建议直接用 Ubuntu VM）；Ubuntu：按 docs.docker.com 官方 apt 源装 `docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin` |
| **浏览器** | Firefox 159 / Brave 1.99 | 隐私友好（Brave 方便装渗透插件） | 官网 / `winget install Mozilla.Firefox Brave.Brave` / apt |

### 二、Windows 11 专属

- **Windows Terminal 1.25** — Win11 自带，`winget upgrade Microsoft.WindowsTerminal`
- **7-Zip 26.06** — 解压：`winget install 7zip.7zip`
- **PowerToys 0.102** — 效率工具：`winget install Microsoft.PowerToys`
- **Everything** — 秒级文件搜索：`winget install voidtools.Everything`
- **包管理** — `winget` 自带；命令行党可加 [Scoop](https://scoop.sh)
- **隐私设置**：设置 → 隐私和安全性 → 关闭"诊断数据/定制体验/活动历史记录/广告 ID/在线语音识别"，按需禁用 Recall/Copilot

### 三、Ubuntu 24.04 专属

```bash
sudo apt install open-vm-tools open-vm-tools-desktop   # VMware 剪贴板/自适应分辨率（必装）
sudo apt install build-essential curl jq httpie        # 编译链与调试抓包
```

- **WSL2 不必装**：已有 Ubuntu VM，Win11 VM 里再开 WSL2 需嵌套虚拟化、开销明显，跨 VM 反而更干净

### 四、安全研究工具（均合法常规工具）

| 工具 | 版本 | 用途 | 安装 |
|---|---|---|---|
| **Burp Suite Community** | 2026.x 月更 | Web 抓包测试代理（需 JDK） | [portswigger.net/burp/communitydownload](https://portswigger.net/burp/communitydownload)（跨平台） |
| **nmap** | 7.993 | 端口/服务扫描 | Win：`winget install Insecure.Nmap`；Ubuntu：apt 版旧可源码装 |
| **Wireshark** | 4.6.9 | 流量分析 | Win：`winget install WiresharkFoundation.Wireshark`（自带 Npcap）；Ubuntu：`sudo apt install wireshark` |
| **sqlmap** | 1.10 | SQL 注入检测（需授权测试） | `git clone --depth 1 https://github.com/sqlmapproject/sqlmap`（通用） |
| **nuclei / subfinder / httpx** | 3.11.1 / 2.17.0 / 1.12.0 | 漏扫/子域枚举/探活 | `go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest`（subfinder/v2、httpx 同法，通用） |
| **ffuf / dirsearch** | 2.3.0 / 0.5.0 | 目录/参数 Fuzz | `go install github.com/ffuf/ffuf/v2@latest`；`pipx install dirsearch` |
| **semgrep** | 1.184.0 | 静态代码审计 | `pipx install semgrep`（通用） |
| **CodeQL CLI** | 2.27.4 | 代码污点分析 | [github.com/github/codeql-cli-binaries/releases](https://github.com/github/codeql-cli-binaries/releases)（通用） |
| **mitmproxy** | 12.3.1 | 中间人代理调试 | `pipx install mitmproxy`（通用） |
| **CyberChef** | — | 编解码"瑞士军刀" | [gchq.github.io/CyberChef](https://gchq.github.io/CyberChef)（网页即用） |
| **Ghidra** | 12.2 | NSA 开源逆向（需 JDK 21+） | [ghidra-sre.org](https://ghidra-sre.org)（通用） |
| **testssl.sh** | 3.0.9+ | TLS/证书检测 | `git clone https://github.com/drwetter/testssl.sh`（通用） |
| **ksubdomain / OneForAll** | 0.7 / 0.4.5 | 子域名快扫（OneForAll 多年停更，谨慎依赖） | [github.com/knownsec/ksubdomain](https://github.com/knownsec/ksubdomain) |
| **Wappalyzer** | — | 浏览器指纹识别插件 | Firefox/Brave 商店：[wappalyzer.com](https://www.wappalyzer.com) |

### 五、其他建议

- 两台 VM 装完基线后**先打 VMware 快照**，之后工具尽量用包管理器装，便于升级和回滚

---

## 内网白盒审计与渗透漏挖工具库

> **场景**：完全离线的内网（air-gapped，无互联网），对已获取的 Java / .NET 内部系统（源码或 jar/war/dll 包）做白盒源码审计、逆向反编译审计、漏洞验证与 PoC 开发。所有工具均可**提前在互联网下载打包、移植进内网后离线运行**；AI 类工具均可**连接本地模型 API**（Ollama / vLLM 等 OpenAI 兼容端点）干活。
>
> **筛选标准**：仅收录官方仓库（GitHub API 于 2026-11 逐一核实 star 数与维护状态，杜绝山寨 fork 投毒）、社区公认、完全离线可用。停更/归档已如实标注。
>
> ⚠️ **全部工具仅限已授权的安全测试场景使用。**

### 一、白盒 SAST 源码审计

| 工具 | 链接 | star | 用途 | 离线用法 |
|---|---|---|---|---|
| **CodeQL** | [github/codeql](https://github.com/github/codeql)（CLI：[codeql-cli-binaries](https://github.com/github/codeql-cli-binaries)，v2.27.x） | 10.3k | Java/C# 深度污点分析，白盒天花板 | 下载 codeql **bundle 离线包**（自带 CLI+全部查询套件，无需联网）；内网 `codeql database create db --language=java` → `codeql database analyze db codeql/java-queries`；C# 建库需 Windows+MSBuild。**许可注意：仅开源项目/安全研究免费，商用需 GitHub 许可** |
| **Semgrep OSS** | [semgrep/semgrep](https://github.com/semgrep/semgrep)（v1.184） | 17.6k | 快速规则扫描 + OSS 污点分析（Java） | 外网 `pip download semgrep -d pkgs` + clone [semgrep-rules](https://github.com/semgrep/semgrep-rules)；内网 `pip install --no-index --find-links=pkgs semgrep` 后 `semgrep --config /rules --metrics=off src/`。**C# 跨文件分析为付费 Pro，内网不可用**（单文件规则可用） |
| **Joern** | [joernio/joern](https://github.com/joernio/joern)（v4.x） | 3.6k | CPG 代码属性图 + 自定义 Scala 查询，Java 白盒利器 | 下载 release zip **解压即用**（勿用联网安装脚本），需 JDK；`./joern-parse src/ && ./joern --script audit.sc`；C# 前端需另装 dotnetastgen（建议锁版本） |
| **Tabby** | [tabby-sec/tabby](https://github.com/tabby-sec/tabby)（原 wh1t3p1g/tabby 已迁移） | 1.7k | Java jar/war/class 生成 CPG，Cypher 查污点链/反序列化链，SRC 社区知名 | release jar + 本地 Neo4j Community（可离线装）+ JDK；`java -jar tabby.jar --ci tabby.yml` 后用 Cypher 查询 |
| **FindSecBugs** | [find-sec-bugs/find-sec-bugs](https://github.com/find-sec-bugs/find-sec-bugs)（1.14.0） | 2.5k | Java 字节码级安全扫描（含 Kotlin/Scala），无需源码构建 | 搭配 SpotBugs CLI：`spotbugs -textui -pluginList findsecbugs-plugin.jar app.jar`，全本地 |
| **Security Code Scan** | [security-code-scan/security-code-scan](https://github.com/security-code-scan/security-code-scan)（5.6.x） | 1k | .NET（C#/VB）Roslyn 安全分析器 | nupkg 预下载 + 本地 NuGet 源，`dotnet build` 触发。**2024-07 起停更**（VS2022 用社区 fork，NuGet 搜 `SecurityCodeScan.VS2022`），规则偏旧 |
| **DevSkim** | [microsoft/DevSkim](https://github.com/microsoft/DevSkim)（CLI v1.0.x） | 1k | 微软官方轻量危险 API/密码学扫描（多语言） | CLI 自带规则集，`devskim analyze -f sarif src/` 纯本地 |

### 二、反编译 / 逆向（拿包审计）

| 工具 | 链接 | star | 用途 | 离线用法 |
|---|---|---|---|---|
| **jadx** | [skylot/jadx](https://github.com/skylot/jadx)（1.5.x） | 51.7k | Java jar/war 反编译首选，维护最勤 | zip 免安装，`jadx -d out app.jar` |
| **Recaf** | [Col-E/Recaf](https://github.com/Col-E/Recaf)（2.x 稳定 / 4.0-alpha） | 7.5k | Java 字节码反编译+编辑器（改 class 重打包） | zip 免安装，2.x 用 Java 11+，4.x 需 Java 22+ |
| **Vineflower** | [Vineflower/vineflower](https://github.com/Vineflower/vineflower)（1.12.x） | 2.5k | Fernflower 维护分支（原版已停维护），反编译质量最佳，已入 IntelliJ | `java -jar vineflower.jar in.jar out/` |
| **CFR** | [leibnitz27/cfr](https://github.com/leibnitz27/cfr)（0.152） | 2.7k | Java 17+ 新语法支持好 | `java -jar cfr.jar app.jar` |
| （JD-GUI / Procyon） | [java-decompiler/jd-gui](https://github.com/java-decompiler/jd-gui) | 15.2k | 老牌但已停更（JD-GUI 2024-07 / Procyon 2022 起），对新语法差，仅作备用 | 绿色免安装 |
| **ILSpy + ilspycmd** | [icsharpcode/ILSpy](https://github.com/icsharpcode/ILSpy)（11.2） | 27k | .NET 反编译标准工具，最活跃 | GUI 版 zip 免安装；命令行批量：外网 `dotnet tool download` 取 nupkg，内网 `--add-source` 本地装，`ilspycmd app.dll -p -o out` |
| **dnSpyEx** | [dnSpyEx/dnSpy](https://github.com/dnSpyEx/dnSpy)（6.5.x） | 11.5k | .NET 反编译 + 实时调试（原 dnSpy 已归档，Ex 分支活跃） | 绿色 zip 免安装 |
| **de4dot → de4dotEx** | [de4dot/de4dot](https://github.com/de4dot/de4dot)（已归档）→ 官方维护分支 [GDATAAdvancedAnalytics/de4dotEx](https://github.com/GDATAAdvancedAnalytics/de4dotEx) | 7.4k / 307 | .NET 脱壳去混淆（处理 ConfuserEx 等加壳 dll） | 绿色免安装，`de4dot.exe app.dll` |

### 三、依赖组件 CVE 审计（SCA）

| 工具 | 链接 | star | 离线用法 |
|---|---|---|---|
| **Trivy** | [aquasecurity/trivy](https://github.com/aquasecurity/trivy)（v0.76） | 39.1k | 外网 `trivy image --download-db-only` + `--download-java-db-only` 导出 DB；内网放入缓存目录后 `trivy fs --skip-db-update --skip-java-db-update app.jar`（java-db 可识别 jar 内嵌依赖，也可扫 .NET 的 deps.json） |
| **osv-scanner** | [google/osv-scanner](https://github.com/google/osv-scanner)（v2.7） | 11.5k | 外网 `osv-scanner update` 拉全 OSV 库打包；内网设 `OSV_SCANNER_LOCAL_DB_CACHE_DIRECTORY` + `--offline-vulnerabilities` |
| **OWASP Dependency-Check** | [dependency-check/DependencyCheck](https://github.com/dependency-check/DependencyCheck)（v12，注意已迁新库） | 7.8k | 外网用 OpenVLK `vulnz` CLI 生成 NVD datafeed 打包；内网指向本地目录 + `--failOnUpdateErrors=false` |

### 四、PoC 验证 / 内网扫描框架

| 工具 | 链接 | star | 用途与离线用法 |
|---|---|---|---|
| **Nuclei** | [projectdiscovery/nuclei](https://github.com/projectdiscovery/nuclei)（v3.11）+ [nuclei-templates](https://github.com/projectdiscovery/nuclei-templates) | 32.7k / 13.3k | 模板化漏洞验证与指纹识别，模板即 PoC。外网克隆模板库，内网 `nuclei -l targets.txt -t <模板目录> -duc`（`-duc` 禁止联网更新检查）；YAML 模板可自行为内部系统编写 |
| **Pocsuite3** | [knownsec/pocsuite3](https://github.com/knownsec/pocsuite3)（3.9k★，注意仓库名全小写） | 3.9k | 知道创宇 404 实验室 PoC 框架，`POCBase` 规范化开发（verify/exploit 分离）。外网 `pip download pocsuite3 -d pkgs`，内网 `pip install --no-index --find-links=pkgs pocsuite3` |
| **fscan** | [shadow1ng/fscan](https://github.com/shadow1ng/fscan)（v2.2.2） | 14.8k | 内网一键存活/端口/弱口令/漏洞扫描，单二进制零依赖。**极易滥用，严格限授权范围** |
| **interactsh** | [projectdiscovery/interactsh](https://github.com/projectdiscovery/interactsh) | 4.6k | OOB 带外检测服务端——内网自建接收端（DNS/HTTP 回连验证 SSRF/盲注等），替代公网 oob 平台 |
| **httpx** | [projectdiscovery/httpx](https://github.com/projectdiscovery/httpx) | 10.6k | 内网存活探测/标题/状态/技术栈识别，无外部依赖。（subfinder 依赖外网数据源，内网无效，故不列） |
| （xray） | [chaitin/xray](https://github.com/chaitin/xray) | 11.8k | 长亭 Web 扫描器**社区版闭源**、更新基本停滞，不符合"开源可审计"标准，仅备查；开源替代用 Nuclei + ZAP |

### 五、Java / .NET 漏洞链验证（仅限授权验证）

| 工具 | 链接 | star | 用途 |
|---|---|---|---|
| **ysoserial** | [frohoff/ysoserial](https://github.com/frohoff/ysoserial) | 9.1k | Java 反序列化 payload 生成的事实标准；`java -jar ysoserial.jar CommonsCollections6 'cmd'`，常用链 CC1-7 / BeanUtils1 / Spring1-2 / JDK7u21 |
| **JYso** | [qi4L/JYso](https://github.com/qi4L/JYso) | 1.8k | ysoserial + JNDIExploit 二合一（原 feihong-cs/JNDIExploit 已 404、镜像不可信），高版本 JDK 适配，404StarLink 成员；`java -jar JYso.jar` 起 LDAP/RMI |
| **ysoserial.net** | [pwntester/ysoserial.net](https://github.com/pwntester/ysoserial.net)（v1.36） | 3.8k | .NET 反序列化 payload；`ysoserial.exe -g ObjectStateFormatter -c "cmd" -f raw`，含 LosFormatter/SoapFormatter/XmlSerializer/DataContractJson 等 gadget |
| **viewgen** | [0xacb/viewgen](https://github.com/0xacb/viewgen) | 675 | ASP.NET ViewState 生成/签名/校验（配合 machineKey）；Python 实现，`pip download` 打包离线 |
| **ShiroAttack2** | [SummerSec/ShiroAttack2](https://github.com/SummerSec/ShiroAttack2) | 2.6k | Apache Shiro 550/721 反序列化检测（key 爆破+回显），release jar 直接跑 |
| **Fastjson 自检** | [safe6Sec/Fastjson](https://github.com/safe6Sec/Fastjson) | 1.9k | Fastjson 版本探测 + 历史漏洞自检 jar（2023-10 停更但功能稳定） |
| **JNDI 注入验证** | [welk1n/JNDI-Injection-Exploit](https://github.com/welk1n/JNDI-Injection-Exploit) / [veracode-research/rogue-jndi](https://github.com/veracode-research/rogue-jndi) | 2.8k / 1.1k | 起 LDAP/RMI 服务验证 JNDI 注入（rogue-jndi 需外网 mvn 编译后带入） |
| **Log4j2** | [fullhunt/log4j-scan](https://github.com/fullhunt/log4j-scan) / Burp 插件 [whwlsfb/Log4j2Scan](https://github.com/whwlsfb/Log4j2Scan) | 3.4k / 830 | CVE-2021-44228 检测；内网 OOB 回连需配合自建 interactsh 服务端 |

### 六、Burp Suite 离线化 + 插件

- **Burp Suite Community**：免费无需激活，[官网](https://portswigger.net/burp/communitydownload) jar 离线可跑；**BApp Store 在线商店内网不可用**——在外网手动下载插件 jar，内网 Extensions → Add → File 手动加载。
- 推荐插件（均官方/原作者仓库）：**HaE**（[overspace-labs/HaE](https://github.com/overspace-labs/HaE)，4.4k★，信息高亮提取）、**Turbo Intruder**（[PortSwigger/turbo-intruder](https://github.com/PortSwigger/turbo-intruder)，1.8k★，高速 fuzz）、**Autorize**（[PortSwigger/autorize](https://github.com/PortSwigger/autorize)，越权检测）。
- 全开源替代：**OWASP ZAP**（[zaproxy/zaproxy](https://github.com/zaproxy/zaproxy)，16.1k★，完全离线）。

### 七、开发 / 复现环境离线化

- **pwntools**（[Gallopsled/pwntools](https://github.com/Gallopsled/pwntools)，13.8k★）：PoC/Exploit 脚本开发库；`pip download pwntools -d pkgs` 离线打包（requests、httpx 等同理）。
- **Vulhub**（[vulhub/vulhub](https://github.com/vulhub/vulhub)，21.5k★）：漏洞复现环境。外网 `docker compose -f vulhub/<组件>/compose.yml pull` → `docker save -o v.tar <镜像>`；内网 `docker load -i v.tar && docker compose up -d`（需预装 Docker+compose 插件）。

### 八、AI 辅助审计（连接本地模型 API，完全离线）

**本地推理底座**（外网下好模型权重，内网导入）：

| 底座 | 链接 | star | 离线模型导入 |
|---|---|---|---|
| Ollama | [ollama/ollama](https://github.com/ollama/ollama) | 186.4k | `FROM ./x.gguf` + `ollama create`（gguf 单文件最好带内网） |
| vLLM | [vllm-project/vllm](https://github.com/vllm-project/vllm) | 96.6k | 拷全模型目录 + `HF_HUB_OFFLINE=1 TRANSFORMERS_OFFLINE=1` 启动，OpenAI 兼容 :8000/v1 |
| Xinference | [xorbitsai/inference](https://github.com/xorbitsai/inference) | 9.6k | docker save/load + register custom model 填 model_path |

**适合本地部署做代码审计的模型**（按显存）：Qwen3-Coder-30B-A3B（Q4≈21GB，单 24G 卡）、Qwen2.5-Coder-32B（Q4≈20GB）/ 14B（≈9GB）、DeepSeek-Coder-V2-Lite-16B（≈11GB）、GLM-4-9B（Q4≈6GB）；长上下文审计需另留 KV cache 显存。

**AI 工具（全部支持自定义 OpenAI 兼容端点）**：

| 工具 | 链接 | star | 本地 API 配置要点 |
|---|---|---|---|
| **LiteLLM Proxy** | [BerriAI/litellm](https://github.com/BerriAI/litellm) | 62.9k | 本地 API 网关：config.yaml 里 `api_base` 指向 Ollama/vLLM，对外统一暴露 OpenAI 格式 ：4000/v1，`master_key` 管控；后端全本地即完全离线 |
| **claude-code-router** | [musistudio/claude-code-router](https://github.com/musistudio/claude-code-router)（v3.1） | 38.1k | 把 **Claude Code 路由到任意自定义/本地 API**：网关(:3456)加 OpenAI 兼容 Provider 指向 `http://localhost:11434/v1`，Claude Code 全部请求走网关——内网用 Claude Code 干活的钥匙 |
| **Aider** | [Aider-AI/aider](https://github.com/Aider-AI/aider) | 50k | `aider --model openai/<模型> --openai-api-base http://内网:8000/v1`（或 `ollama_chat/` 前缀）；AI 结对改代码/写 PoC |
| **OpenCode** | [sst/opencode](https://github.com/sst/opencode)（已迁 anomalyco，旧地址仍有效） | 225.6k | opencode.json 配 ollama / openai-compatible provider，`baseURL` 指向本地端点 |
| **Continue.dev** | [continuedev/continue](https://github.com/continuedev/continue) | 36.4k | IDE 插件（VS Code/JetBrains），config.yaml `provider: ollama` 或任意 openai-compatible `apiBase` |
| **DeepAudit** | [lintsinghua/DeepAudit](https://github.com/lintsinghua/DeepAudit) | 7.3k | 中文社区多 Agent 代码审计 + 沙箱 PoC 验证，README 明示支持 Ollama 私有部署；AGPL |
| **VulnHuntr** | [ProtectAI/vulnhuntr](https://github.com/ProtectAI/vulnhuntr) | 2.8k | LLM 白盒链式漏洞挖掘（**仅 Python 代码**）；`-l ollama` + `OLLAMA_BASE_URL`（官方标注实验性）；2025-02 后更新放缓 |

### 九、安全 Skills 集合（Claude Code 类 CLI 通用，纯文本离线）

装载方式：放 `~/.claude/skills/`（全局）或项目 `.claude/skills/`；zcode 读 `~/.zcode/skills/` 与 `~/.agents/skills/`，与 Claude skills 体系互通。

| 集合 | 链接 | star | 内容 |
|---|---|---|---|
| **anthropics/skills** | [链接](https://github.com/anthropics/skills) | 189.9k | Anthropic 官方技能库（文档处理、webapp-testing、skill-creator 等），无渗透类 |
| **obra/superpowers** | [链接](https://github.com/obra/superpowers) | 314.7k | 最流行的开发方法论 skills（TDD/调试/系统性计划），提升 agent 工程纪律 |
| **wshobson/agents** | [链接](https://github.com/wshobson/agents) | 42.3k | 80+ 域 subagent 库，安全类：backend-api-security、security-scanning、incident-response、reverse-engineering 等 |
| **zhaoxuya520/reverse-skill** | [链接](https://github.com/zhaoxuya520/reverse-skill) | 44.3k | 中文社区最火的逆向/渗透/安全技能路由包（中英双语，Claude Code/Kiro/Cursor 通用） |
| **SnailSploit/Claude-Red** | [链接](https://github.com/SnailSploit/Claude-Red) | 10.5k | 渗透测试技能库（注入类漏洞→验证→PoC 开发流程），⚠️ 仅限授权环境 |
| **mukul975/Anthropic-Cybersecurity-Skills** | [链接](https://github.com/mukul975/Anthropic-Cybersecurity-Skills) | 35.8k | 817 个安全技能，按 MITRE ATT&CK / NIST CSF 等框架映射 29 个域 |
| **gadievron/raptor** | [链接](https://github.com/gadievron/raptor) | 4k | Claude Code 攻防一体 agent 配置（rules + sub-agents + skills） |
| **NVIDIA/SkillSpector** | [链接](https://github.com/NVIDIA/SkillSpector) | 24.9k | **装任何第三方 skill 前的供应链/提示注入扫描器**——配合本仓库"无投毒"原则，第三方 skills 先过它再上车 |
| （本仓库自带） | `files/claude/skills/clown-src-skill` | — | 漏洞测试知识库（各类漏洞测试方法），配合 `files/claude/rules/` 白盒/黑盒工作流使用 |

### 离线移植总原则

1. **外网备齐**：release 二进制 / jar / shaded 包、`pip download -d` wheels、`docker save` 镜像、模板与字典目录、JDK / .NET / Python 运行时、模型权重文件（gguf/safetensors）。
2. **内网运行**：一律加离线开关——pip `--no-index`、nuclei `-duc`、trivy `--skip-db-update`、vLLM `HF_HUB_OFFLINE=1`，防止工具自动外联。
3. **防投毒**：只从上表官方仓库下载 release；避免使用来历不明的镜像/fork；第三方 skills 用 SkillSpector 扫描后再装载。

---

## 声明

- 本仓库仅供**学习与授权安全研究**用途；所有安全工具仅可在获得授权的目标上使用。
- 学习资料（压缩包）仅供个人备份学习，如有侵权请联系删除。
- 调研信息（版本、价格、免费额度）截至 **2026-11**，会随时间失效，以官方页面为准；标注【待核实】/【未核实】处请自行甄别。
