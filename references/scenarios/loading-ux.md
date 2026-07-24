# L1 — Loading UX（加载 / 骨架 / 空态）

## 适用信号

Loading、Skeleton、Spinner、空态、错误态、感知性能；与具体业务 playbook 叠加。

---

## 标准解法

### 1. 选对反馈

| 情况 | 反馈 |
|------|------|
| <100ms 常可完成 | 可不显示 |
| 布局已知 | 骨架屏（减 CLS） |
| 布局未知/动作中 | 按钮内 spinner / 局部遮罩 |
| 全页阻断 | 慎用；优先局部 |

### 2. 防闪烁

最短展示时间（如 200ms）或延迟出现（如 150ms 后才显示 loading），避免闪一下。

### 3. 保留旧内容

刷新同屏数据时，保留上一份结果 + 轻量指示，优于整页清空。

### 4. 空与错

空态给下一步行动；错误态可重试；不要静默空白。

---

## 反模式

```tsx
// ❌ 每次 keypress 全页 Loading 闪烁
// ❌ 骨架与真实布局差异巨大 → 更大 CLS
// ❌ 错误时空白无重试
```

---

## 相关

- [search.md](search.md) · [list-scroll.md](list-scroll.md) · [form-input.md](form-input.md)
- `../patterns.md` Skeleton / SSR Streaming
