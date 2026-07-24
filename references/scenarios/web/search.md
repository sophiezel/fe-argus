# L2 Web — Search

增量（相对 [../search.md](../search.md)）：

- 桌面：`input[type=search]`、快捷键 `/` 聚焦时勿与浏览器冲突
- Safari：composition 事件顺序与 Chrome 略有差异，以 `compositionend` 为准再搜
- History：可选把 q 写入 querystring；注意防抖写入避免污染历史

```ts
// ✅ 仅在搜索提交或 debounce 稳定后 replaceState
```
