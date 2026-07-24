# L2 Hybrid — Scroll Lock

> Q 命中弹层/滚动穿透 + Hybrid 时加载。相对 [overlay.md](../overlay.md)。

## 适用信号

WebView 内 Modal/遮罩；背景仍滚动；关闭后跳到页顶；多弹层关不干净。

---

## 标准解法

1. **记 scrollY** 再锁：`body { position:fixed; top:-y; width:100% }`；关闭后清 style 并 `scrollTo(0,y)`（见 L1）
2. iOS：仅 `overflow:hidden` **经常无效**——必须配合 fixed 方案
3. 弹层内部滚动容器：独立 `overflow:auto`；谨慎 `touchmove preventDefault`（非 passive）挡穿透，注意嵌套滚动卡顿
4. 多弹层：**单一** body-lock 管理器（引用计数），禁止每个弹层各自改 body 互覆盖
5. Android WebView 行为碎片化——锁滚/穿透必须真机验（pit-022 环境）

## 反模式

```ts
// ❌ 打开不记 scrollY → 关闭跳顶
// ❌ 多实例各自改 body.style，关闭后 style 残留
// ❌ 对 document 无脑 preventDefault 导致弹层内无法滚
```

## 相关

- [../overlay.md](../overlay.md)
- pit-022
