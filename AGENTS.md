# AGENTS.md — fe-argus (Argus) 跨 Agent 入口

> 本文件是 **agent-agnostic** 入口，供 Cursor / Continue / Windsurf / Aider / Copilot 等
> 非 Claude-Code-native agent 读取。Claude Code 和 PI 直接读 `SKILL.md`。
> Single source of truth 在 `references/`，本文件只做 trigger + 路由。

---

## Trigger（什么时候启用 fe-argus）

**凡将写或修改前端代码**（`.ts` / `.tsx` / `.jsx` / `.js` / `.vue` / `.css` / `.scss` / `.html` / `vite.config.*` / `webpack.config.*` / `next.config.*`），MUST 先走 Coding Gate。

包括但不限于：组件实现、状态管理、构建配置、性能优化、搜索/表单/Hybrid/RN 场景、SSR/SSG、微前端、AI 前端集成。

---

## Coding Gate（写代码前强制，无条件）

**回复第一句 MUST 是 Tier 声明**：`**Tier：T0|T1|T2** — <一句话理由>`

- **T0**：trivial 单组件 / 一行修复（仍要声明，不能不报）
- **T1（默认）**：常规业务代码
- **T2**：架构选型 / 性能 / 跨端 / TypeScript 工程化

然后按 Tier 加载规则（见下文「知识索引」）。

---

## NEVER 清单（写代码时永不违反）

1. **NEVER 未读对应 pitfall 就修** — 跳过诊断大概率引入新问题
2. **NEVER 修复中顺手重构** — 两事务分离
3. **NEVER 用 100vh 当全屏高度** — 用 `100dvh` / `100svh` / `100lvh` 或 `position:fixed + inset:0`
4. **NEVER 在 useEffect 依赖里放引用字面量** — 易死循环
5. **NEVER 对金钱用原生浮点** — 整数分 / 字符串 / Decimal / branded type
6. **NEVER CI 跳过兼容性检查**
7. **NEVER 无限制 `backdrop-filter`** — 移动端合成层爆炸
8. **NEVER 未完整诊断就下结论**
9. **NEVER 因「prompt 简单」跳过 Tier 声明** — trivial 报 T0 即可，不能不报
10. **NEVER 顺从「超级通用 / 全 variant / 全场景可配置」类过度泛化请求** — 单一用例 MUST 先内联；询问「第二处真实复用何时出现」前不得堆 variant × size × icon 矩阵

---

## 场景路由（按任务类型读对应规则）

| 场景 | 触发信号 | 必读 |
|---|---|---|
| **P 编码** | 写代码 | `references/coding/quality.md` + 当前栈（react.md / vue.md） |
| **Q 功能场景** | 搜索/表单/键盘/滚动/列表/WebView | `references/scenarios/INDEX.md` → 命中 L1（+L2） |
| **A 诊断** | Bug / 白屏 / 性能 / 卡死 | `references/pitfalls/INDEX.md` → 命中 `pit-XXX.md` |
| **B 架构选型** | 技术选型 / 状态管理 / 渲染模式 | `references/decisions.md` |
| **C 性能** | Web Vitals / 性能预算 | `references/performance-engineering.md`（渐进） |
| **D 多终端兼容** | 兼容矩阵 / Safari 怪癖 | `references/compatibility-matrix.md` |
| **E AI 前端** | 流式 / Token / RAG | `references/ai-frontend-patterns.md` |
| **F 代码审查** | Review | `references/checklist.md` |
| **G 可观测性** | Sentry / RUM / 埋点 | `references/frontend-observability.md`（渐进） |
| **H 小程序** | 微信/支付宝小程序 | `references/miniprogram-architecture.md` |
| **I 跨端选型** | RN / Taro / uni-app / Flutter Web | `references/cross-platform-architecture.md` |
| **J TypeScript** | 类型工程化 / 严格化 | `references/typescript-engineering.md` |
| **K 安全审计** | XSS / CSP / 供应链 | `references/frontend-security.md` |
| **L PWA** | Service Worker / 离线 | `references/pwa-offline-architecture.md` |
| **M 国际化** | i18n / ICU / RTL | `references/i18n-architecture.md` |
| **N Edge/Serverless** | CF Workers / Vercel Edge | `references/edge-serverless-architecture.md` |

> **渐进读原则**：>400 行的文档先读目录/章首导航，只加载匹配章节，禁止默认整文件灌入上下文。

---

## 知识索引（SSOT 路径）

完整规则在以下路径，按需 grep / 读：

- `SKILL.md` — 完整协议（Claude Code / PI 原生读这个）
- `references/coding/` — 通用编码规则（quality / react / vue / js-core）
- `references/scenarios/` — 功能场景标准解法（L1 跨环境 + L2 环境增量）
- `references/pitfalls/` — 79 个架构级陷阱（按症状/技术栈/场景索引）
- `CONTEXT.md` — 术语表

---

## 跨 Agent 注入

本文件由 `adapters/link.sh` 自动注入到各 agent 全局配置：

- Claude Code → `~/.claude/CLAUDE.md` 加 `@~/.agents/skills/fe-argus/AGENTS.md`
- PI → `~/.pi/agent/settings.json` 的 `skills` 数组
- Cursor → `~/.cursor/rules/fe-argus.mdc`（精简版 + glob 触发）
- Continue / Windsurf / Aider → symlink 到各自 `skills/fe-argus/`

跑 `bash adapters/link.sh` 一键注入；`--unlink` 回滚；`--check` 检查状态。
