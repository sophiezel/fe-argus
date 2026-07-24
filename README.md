# fe-argus (Argus)

[![evals](https://github.com/sophiezel/fe-argus/actions/workflows/evals.yml/badge.svg)](https://github.com/sophiezel/fe-argus/actions/workflows/evals.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Release](https://img.shields.io/github/v/release/sophiezel/fe-argus)](https://github.com/sophiezel/fe-argus/releases)

> 前端架构与编码质量门 — 一个 skill，全 agent 通用（Claude Code / Cursor / Continue / Windsurf / PI / Aider）。
>
> `fe` = frontend 域；`Argus` = 百眼——写前质量门 / 场景命中 / 陷阱扫描。

Argus 给所有 AI 编码 agent 装上同一套前端守门规则：写代码前先报 Tier、加载场景 playbook、规避 79 个架构级陷阱、永不踩 10 条 NEVER。

## 为什么需要

| 没有 Argus | 有 Argus |
|---|---|
| AI 看到"简单需求"就直接吐代码 | 必须先报 Tier，trivial 报 T0 也要走协议 |
| 搜索框漏 IME 门闸、漏竞态控制 | 自动命中 scenarios/search.md，输出 IME + debounce + AbortController 三件套 |
| 100vh 上线后 iOS 工具栏遮挡 | NEVER #3 拦截，强制 100dvh 或 fixed+inset:0 |
| 用户要"超级通用 Button"，AI 堆 7×5 variant 矩阵 | NEVER #10 反推"先内联，等第二处真实复用" |
| 每个 agent 配一遍规则，改一处要同步 N 处 | 改 `references/` 一次，6 个 agent 立即同步 |

## 快速开始

### 一键安装

```bash
# 方式 1：clone 后跑（推荐，可改规则）
git clone https://github.com/sophiezel/fe-argus.git ~/.agents/skills/fe-argus
bash ~/.agents/skills/fe-argus/install.sh

# 方式 2：curl 一键（只读使用）
curl -fsSL https://raw.githubusercontent.com/sophiezel/fe-argus/main/install.sh | bash

# 方式 3：SSH 仓库地址（已配 SSH key 时）
FE_ARGUS_REPO=git@github.com:sophiezel/fe-argus.git \
  curl -fsSL https://raw.githubusercontent.com/sophiezel/fe-argus/main/install.sh | bash

# 方式 4：锁定版本（生产推荐，避免 main 漂移）
FE_ARGUS_BRANCH=v1.0.0 \
  curl -fsSL https://raw.githubusercontent.com/sophiezel/fe-argus/v1.0.0/install.sh | bash
```

> **HTTPS vs SSH**：install.sh 内部 `git clone` 默认用 HTTPS（公开仓库免 token）；
> 想用 SSH 时设 `FE_ARGUS_REPO=git@...` 环境变量覆盖。`curl | bash` 下载脚本本身必须用 HTTPS。
>
> **锁定版本**：生产环境用 `FE_ARGUS_BRANCH=v1.0.0` 锁定 release tag，避免 main 分支规则漂移。
> 见 [Releases](https://github.com/sophiezel/fe-argus/releases) 查看所有版本。

安装脚本会：
1. 检查 `bash / python3 / git` 依赖
2. 把 fe-argus 放到 `~/.agents/skills/fe-argus/`
3. 调 `adapters/link.sh` 注入到所有检测到的 agent 全局配置
4. 打印验证步骤

### 验证

```bash
cd ~/.agents/skills/fe-argus
skill-up run evals/eval.yaml
```

预期：5/6 PASS（`coding-gate-tier` 在 GLM 上不 compliance，是模型限制非 skill 缺陷）。

### 触发它

在任何 agent 里说：

```
帮我实现一个搜索框，要支持中文输入法
```

如果 agent 已被 link，你会在响应顶部看到：
```
**Tier：T1** — 常见组件，需严守 IME 门闸 / 请求竞态 / 防抖。
```

## 它能帮你做什么

### 1. Coding Gate（写代码前强制协议）

任何写/改前端代码请求，第一句 MUST 是 Tier 声明：

- **T0** — trivial 单组件 / 一行修复
- **T1**（默认）— 常规业务代码
- **T2** — 架构选型 / 性能 / 跨端 / TypeScript 工程化

按 Tier 自动加载规则：
- T0：只读 CONTEXT.md
- T1：`coding/quality.md` + 当前栈 `react.md`/`vue.md`
- T2：T1 + `coding/js-core.md` + `patterns.md`

### 2. 场景路由（按任务类型读 playbook）

16 个场景 A–R，每个都有标准解法 + 反模式 + 环境增量。

| 场景 | 触发信号 | 命中文档 |
|---|---|---|
| Q 搜索 | 搜索框 / IME / 防抖 / 即时建议 | `scenarios/search.md` |
| Q 表单 | 表单提交 / 校验 / IME | `scenarios/form-input.md` |
| Q 列表 | 长列表 / 虚拟滚动 | `scenarios/list-scroll.md` |
| Q 浮层 | Modal / 滚动穿透 / focus trap | `scenarios/overlay.md` |
| A 诊断 | Bug / 白屏 / 性能 | `pitfalls/INDEX.md` → `pit-XXX.md` |
| C 性能 | Web Vitals / 性能预算 | `performance-engineering.md` |
| I 跨端 | RN / Taro / uni-app / Flutter | `cross-platform-architecture.md` |
| K 安全 | XSS / CSP / 供应链 | `frontend-security.md` |

完整 16 个场景见 `SKILL.md` 或 `AGENTS.md`。

### 3. NEVER 清单（10 条硬禁）

1. 未读对应 pitfall 就修
2. 修复中顺手重构
3. 用 100vh 当全屏高度 → 用 100dvh / fixed+inset:0
4. useEffect 依赖里放引用字面量
5. 金钱用原生浮点 → 整数分 / Decimal / 字符串
6. CI 跳过兼容性检查
7. 无限制 backdrop-filter
8. 未完整诊断就下结论
9. 因「prompt 简单」跳过 Tier 声明
10. 顺从「全 variant 超级通用」过度泛化请求（单一用例先内联）

### 4. 79 个架构级陷阱

`references/pitfalls/pit-001.md` ~ `pit-079.md`，覆盖：
- React / Vue / Hooks（pit-001～005, 030～034）
- CSS / 视口 / 渲染（pit-006～010）
- JavaScript 语言（pit-015～020：浮点 / Promise / async / Date / map）
- 构建部署（pit-011～013：chunk 404 / Tree Shaking / HMR）
- TypeScript 工程化（pit-062, 063, 069）
- 前端安全（pit-064～068：XSS / CSP / 供应链 / JWT）
- 可观测性（pit-046～050：RUM / Sentry / 埋点 / 性能预算）
- 跨端框架（pit-057～061：Taro / RN / uni-app / Flutter Web）

每个 pitfall 都有：症状 / 根因 / 诊断方法 / 修复 / 验证 / 架构视角 / 预防策略 / 跨层影响链。

## 各 agent 支持矩阵

| Agent | 注入方式 | 触发强度 |
|---|---|---|
| **Claude Code** | `~/.claude/CLAUDE.md` 加 `@import` | 强（原生 SKILL.md） |
| **PI** | `~/.pi/agent/settings.json` skills 数组 | 强（原生 SKILL.md） |
| **Cursor** | `~/.cursor/rules/fe-argus.mdc` | 强（glob 触发：`**/*.{tsx,jsx,vue,css}`） |
| **Continue** | `~/.continue/skills/fe-argus` symlink | 中（rules 软引导） |
| **Windsurf** | `~/.codeium/windsurf/skills/fe-argus` symlink | 中 |
| **Aider** | `~/.aider-desk/skills/fe-argus` symlink | 中 |

Cursor / Claude Code / PI 在编辑前端文件时强制加载；其他 agent 软引导（依赖 LLM 路由）。

### 查看状态 / 回滚

```bash
bash ~/.agents/skills/fe-argus/adapters/link.sh --check    # 查看注入状态
bash ~/.agents/skills/fe-argus/adapters/link.sh --unlink   # 回滚所有注入
bash ~/.agents/skills/fe-argus/install.sh --uninstall      # 完全卸载
```

## 目录结构

```
fe-argus/
├── SKILL.md              # Claude Code / PI 原生入口（完整协议）
├── AGENTS.md             # 跨 agent 入口（agent-agnostic 精简版）
├── CONTEXT.md            # 术语表
├── README.md             # 本文档
├── install.sh            # 一键安装 / 卸载
│
├── adapters/
│   └── link.sh           # 注入到 6 个 agent 全局配置（idempotent + 可逆）
│
├── evals/                # skill-up 评测基线（6 case）
│   ├── eval.yaml
│   └── cases/
│       ├── coding-gate-tier.yaml
│       ├── money-float-antipattern.yaml
│       ├── mobile-viewport-dvh.yaml
│       ├── search-ime-routing.yaml
│       ├── white-screen-diagnosis.yaml
│       └── over-engineering-resistance.yaml
│
└── references/           # SSOT — 所有规则正文（agent 按需读）
    ├── coding/           # 通用 + 框架编码规则
    │   ├── quality.md    #   YAGNI / 抽象频率 / 命名 / 单一职责
    │   ├── react.md      #   React 反模式
    │   ├── vue.md        #   Vue 反模式
    │   └── js-core.md    #   JS 语言陷阱
    ├── scenarios/        # 16 个场景的标准解法 + 反模式
    │   ├── INDEX.md      #   场景路由 L0 索引
    │   ├── search.md     #   搜索 / IME / 竞态
    │   ├── form-input.md
    │   ├── overlay.md
    │   └── hybrid/ rn/   #   环境增量 L2
    ├── pitfalls/         # 79 个架构级陷阱
    │   ├── INDEX.md      #   按症状/栈/标签三索引
    │   └── pit-001.md ~ pit-079.md
    ├── decisions.md      # 架构选型决策树
    ├── patterns.md       # 架构模式 + 反模式
    ├── checklist.md      # Code Review 清单
    ├── diagnostic-mode.md          # 分层诊断方法论
    ├── performance-engineering.md  # 性能工程（Web Vitals / 预算）
    ├── frontend-observability.md   # 可观测性（RUM / Sentry / 埋点）
    ├── compatibility-matrix.md     # 多终端兼容矩阵
    ├── cross-platform-architecture.md
    ├── ai-frontend-patterns.md
    ├── frontend-security.md
    ├── typescript-engineering.md
    ├── miniprogram-architecture.md
    ├── pwa-offline-architecture.md
    ├── i18n-architecture.md
    ├── edge-serverless-architecture.md
    └── knowledge-map.md
```

## 评测

fe-argus 自带 6 个 `skill-up` 评测用例，覆盖协议 / 反模式 / 场景 / 诊断 / 过度设计。

```bash
# 跑全量
skill-up run evals/eval.yaml

# 跑单个
skill-up run evals/eval.yaml --include-case-name "search-*"

# 看报告
open fe-argus-workspace/iteration-N/report.html
```

当前基线（GLM-5.2，iteration-4）：**5/6 PASS**

| Case | 验证点 |
|---|---|
| `coding-gate-tier` | Coding Gate Tier 声明（GLM 上 FAIL — 模型限制）|
| `money-float-antipattern` | NEVER #5 整数分 + Math.round 边界 |
| `mobile-viewport-dvh` | NEVER #3 dvh 或 fixed+inset:0 |
| `search-ime-routing` | 场景 Q IME + debounce + Abort 三件套 |
| `white-screen-diagnosis` | 场景 A 分层诊断 + pitfall 命中 |
| `over-engineering-resistance` | NEVER #10 反推 280 种组合 / 279 不被测试 |

### CI 自动回归

PR / push 到 main 时自动跑 evals（`.github/workflows/evals.yml`）：

- 改 `SKILL.md` / `references/` / `evals/` 触发
- 跑 `skill-up validate` + `skill-up run`，上传 HTML report 为 artifact（保留 14 天）
- 无 API token 时自动 skip 并提示加 secret，不阻塞 PR

**要在 fork / 自己机器复现 CI**：

```bash
# 1. 装 skill-up
curl -fsSL https://raw.githubusercontent.com/alibaba/skill-up/main/install.sh | bash

# 2. 跑 evals（需要 Claude Code 或兼容的 Anthropic API）
skill-up run evals/eval.yaml

# 3. 看 report
open fe-argus-workspace/iteration-*/report.html
```

**配置 GitHub Action 跑 evals**：

repo Settings → Secrets and variables → Actions，加：

| Secret | 必需 | 说明 |
|---|---|---|
| `ANTHROPIC_AUTH_TOKEN` | ✅ | API token（直连 Anthropic 或代理） |
| `ANTHROPIC_BASE_URL` | 代理时必需 | 如 `https://open.bigmodel.cn/api/anthropic` |
| `ANTHROPIC_MODEL` | 代理时必需 | 如 `glm-5.2` |

## 跨 Agent 注入原理

`adapters/link.sh` 是 idempotent + 可逆的注入器：

```
SSOT: fe-argus/references/  （规则只有一份）
                │
        ┌───────┼───────┬───────┬─────────┬───────────┬─────────┐
        ▼       ▼       ▼       ▼         ▼           ▼         ▼
     Claude    PI    Cursor  Continue  Windsurf     Aider    (future)
       Code                                         
        │       │       │       │         │           │
     @import  skills   .mdc   symlink   symlink   symlink
              array   (glob)  (full dir)(full dir)(full dir)
```

- **PI / Claude Code**：原生读 `SKILL.md`（强触发 + 全套协议）
- **Cursor**：`.mdc` frontmatter 的 `globs: **/*.{tsx,jsx,vue,css}` 触发，编辑前端文件时强制加载精简规则
- **Continue / Windsurf / Aider**：symlink 整个 fe-argus 目录到各自 `skills/`，agent 按需读 `AGENTS.md` 或 `SKILL.md`

改 `references/` 一次，6 个 agent 立即看到更新（symlink + @import + settings.json 都指向同一目录）。

## 自定义

### 改规则

直接编辑 `references/*.md`。所有 agent 通过 symlink / @import 立即看到。

### 加新 agent

在 `adapters/link.sh` 加一个 `link_xxx` 函数，在 `main` 里调用即可。

### 加新场景 playbook

1. 在 `references/scenarios/` 加 `your-scenario.md`
2. 在 `references/scenarios/INDEX.md` 加路由条目
3. （可选）在 `evals/cases/` 加一个回归 case

### 加新 pitfall

1. 在 `references/pitfalls/` 加 `pit-XXX.md`
2. 在 `INDEX.md` 三索引（按症状 / 标签 / 模式）各加条目
3. 在 `SKILL.md` 的「按症状查找」表加条目

## 贡献

PR welcome。请：

1. 改规则 / 加场景 / 加 pitfall
2. 加对应 eval case（`evals/cases/`）
3. 跑 `skill-up run evals/eval.yaml` 确认不回归
4. 提 PR，描述场景 + 评测结果
5. PR 用 [Keep a Changelog](https://keepachangelog.com/) 风格的 label（`feat` / `fix` / `docs` / `ci` / `test` / `refactor`），便于自动归类到 [CHANGELOG](CHANGELOG.md) 和 Release notes

## Changelog

详见 [CHANGELOG.md](CHANGELOG.md)。每个 release 的 notes 由 `.github/release.yml` 按 PR label 自动分类生成。

发新版本：

```bash
# 1. 更新 CHANGELOG.md 的 [Unreleased] -> [vX.Y.Z]
# 2. commit + push main
# 3. 打 tag + release（自动生成 notes）
gh release create vX.Y.Z --generate-notes
```

## License

MIT
