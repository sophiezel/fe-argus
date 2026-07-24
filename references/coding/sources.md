# Coding Canon — Sources & Distillation Queue

> 维护用。默认 **不** 在 Coding Gate 加载本文件。

## 已吸收进种子正文的来源取向

| 领域 | 来源取向 | 落点 |
|------|----------|------|
| 简洁/抽象 | YAGNI、最小改动、Clean Code 命名思想、开源（React/Vue 官方示例风格） | `quality.md` |
| React | React 官方 docs（You Might Not Need an Effect）、Kent C. Dodds 常见建议、并发特性文档 | `react.md` |
| Vue | Vue 3 官方指南（reactivity、computed vs watch） | `vue.md` |
| JS 核心 | YDKJS 心智（scope/this/types/async）、可维护 JS 子集 | `js-core.md` |

## 加深队列（后续蒸馏）

- [ ] 《JavaScript 高级程序设计》— 事件/网络章节可执行规则
- [ ] 《你不知道的 JavaScript》全卷 — 补类型强制、生成器边界案例
- [ ] 《JavaScript 语言精粹》— 坏特性黑名单对照表
- [ ] Node.js 最佳实践（错误优先、流、背压）— 可选 `node.md`
- [ ] 《重构》前端向 — 代码坏味道 → 本仓示例
- [ ] 开源对照：redux toolkit / tanstack query / vueuse 中的竞态与取消模式摘录

## 写入约定

新增规则必须带：适用边界 + ❌/✅；能链 `pit-XXX` 则链；禁止粘贴大段书摘。
