# L2 Hybrid — Scroll Lock

增量：WebView 内弹层滚动穿透。

## 要点

- iOS：仅 `overflow: hidden` 常无效；用 body `position: fixed` + 还原 `scrollY`（见 L1）
- 弹层内部滚动容器需 `-webkit-overflow-scrolling: touch`，并 `touch-action` 谨慎设置
- 遮罩上 `touchmove preventDefault`（非 passive）可挡穿透，注意性能与 nested scroll
- Android WebView 表现不一，真机验证（pit-022 相关环境）

## 反模式

```ts
// ❌ 打开弹层不记 scrollY，关闭后跳到页顶
// ❌ 多个弹层各自改 body style 互相覆盖，关闭后样式残留
```
