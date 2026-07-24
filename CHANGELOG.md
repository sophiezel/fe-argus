# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
