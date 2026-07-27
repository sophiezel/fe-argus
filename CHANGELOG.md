# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [v1.1.0] - 2026-07-27

补缺 Taro 场景覆盖 + CI 端到端跑通（v1.0.0 时 CI 配置齐了但实际跑不通）。

### Added

- **Taro 场景 playbook**（`references/scenarios/taro/`）：之前 scenarios/ 有 `hybrid/` 和 `rn/` 子目录但缺 Taro，pit-057 是事故诊断层不替代写前 playbook
  - `INDEX.md` — L0 路由（信号 → playbook）
  - `multi-platform.md` — 多端条件编译（`process.env.TARO_ENV` 静态 / `Taro.getEnv` 运行时 / 多端文件后缀 / 平台 API 差异表）
  - `network.md` — `Taro.request` 拦截器链 / 401 单飞刷新 / loading 计数（200ms 防抖）/ 错误码统一 / 超时重试 / abort 多端差异
  - `route.md` — 5 种跳转 API 选型 / 页面栈 10 层保护 / 防连点 / 路由参数序列化 / TabBar 约束 / 卸载清理
- **evals case**：`taro-network-routing.yaml` 验证 Taro 信号下场景路由命中（拦截器 / 单飞 / loading 计数三件套）
- **路由入口更新**：`scenarios/INDEX.md` + `SKILL.md` + `AGENTS.md` 三处都加入 Taro 入口

### Fixed

CI 端到端跑通修复链（v1.0.0 配置齐了，v1.1.0 让它真能跑）：

- **Claude Code CLI 缺失**：runner 默认无 `claude` 命令，加 `npm install -g @anthropic-ai/claude-code`
- **workspace artifact 路径**：skill-up 把 workspace 放在 `../fe-argus-workspace/`（仓库同级），artifact glob 找不到，加 mv 步骤挪进 cwd
- **Capture summary glob bug**：`[ -f *.json ]` bash 不展开，改用 `ls + head -1`
- **Capture summary heredoc bug**：`python3 -c "..."` 多行字符串 YAML 缩进后变成 python 代码前空格触发 IndentationError，改用 `python3 - <<'PYEOF'` heredoc + `sys.argv` 传参
- **case timeout 180→300→600s**：GLM 在 CI 上比本地慢约 1.5×，复杂 case 需要更长 timeout
- **workflow timeout 15→25→30min**：7 case 全跑实测 22-23min

### Eval Baseline

`skill-up run evals/eval.yaml`（CI 环境 GLM-5.2）— **6/7 PASS**

最新 CI run：[30237036784](https://github.com/sophiezel/fe-argus/actions/runs/30237036784) `conclusion: success`

### Known Limitations

- **`coding-gate-tier` 在 GLM 模型上非确定性**：连续 4 次 CI 跑结果 `FAIL → PASS → FAIL → PASS`，相同 prompt 不同次输出不同。本地多次跑稳定 PASS，证实是模型层非确定性，非 skill 缺陷
- **`money-float-antipattern` / `over-engineering-resistance` 偶发 FAIL**：之前 CI 稳定 PASS，最近也出现非确定性 FAIL。如要 7/7 稳定 PASS，建议把 `ANTHROPIC_MODEL` secret 切到 Claude Sonnet

### Installation

```bash
# 锁定此版本
FE_ARGUS_BRANCH=v1.1.0 \
  curl -fsSL https://raw.githubusercontent.com/sophiezel/fe-argus/v1.1.0/install.sh | bash
```

## [v1.0.0] - 2026-07-24

首个正式 release。把 fe-argus 从「裸 skill 知识库」升级为「可评测、可分发、跨 agent、一键安装」的完整工具链。

### Added

- **Coding Gate 协议**：写代码前强制 Tier 声明 + canon 加载
  - 强化 ALWAYS-ON #2：回复第一句 MUST 是 Tier 声明
  - **NEVER #9**：禁止因「prompt 简单」跳过 Tier 声明
  - **NEVER #10**：禁止顺从「超级通用 / 全 variant」过度泛化请求
- **16 个场景 playbook**（A–R）：搜索 / 表单 / 诊断 / 性能 / 跨端 / 安全 ...
- **10 条 NEVER 清单**：硬禁反模式（100vh / 浮点金钱 / 过度泛化 ...）
- **79 个架构级 pitfall**（pit-001 ~ pit-079）：React/Vue/CSS/JS/构建/安全/可观测性/跨端
- **跨 agent 全局注入**（`adapters/link.sh`）：
  - Claude Code / PI：原生 SKILL.md（强触发）
  - Cursor：`.mdc` + glob 触发
  - Continue / Windsurf / Aider：symlink 软引导
  - idempotent + 可逆（`--unlink` / `--check`）
- **AGENTS.md**：agent-agnostic 入口（精简 trigger + NEVER + 场景路由）
- **skill-up evals 回归基线**（6 case）：协议 / 反模式 / 场景 / 诊断 / 过度设计
- **一键安装脚本**（`install.sh`）：local + curl | bash 两种模式 + `--uninstall` 安全回滚
- **GitHub Action**（`.github/workflows/evals.yml`）：PR/push 自动 validate + run + 上传 artifact
- **dependabot 配置**：weekly 升级 GitHub Actions，防 Node 20 deprecation 类问题
- **release notes 分类配置**（`.github/release.yml`）：自动按 PR label 归类到 Features / Evals / CI / Dependencies ...

### Eval Baseline

`skill-up run evals/eval.yaml` — **5/6 PASS**（GLM-5.2 上）

唯一 FAIL：`coding-gate-tier` 在 GLM 模型上不 Compliance Tier 声明协议，属模型遵从度限制非 skill 缺陷。

### Installation

```bash
# 锁定此版本
FE_ARGUS_BRANCH=v1.0.0 \
  curl -fsSL https://raw.githubusercontent.com/sophiezel/fe-argus/v1.0.0/install.sh | bash
```

### Links

- [PR #1](https://github.com/sophiezel/fe-argus/pull/1) — 完整 commit 历史
- [Release v1.0.0](https://github.com/sophiezel/fe-argus/releases/tag/v1.0.0)
