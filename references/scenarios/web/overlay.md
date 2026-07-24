# L2 Web — Overlay

增量（相对 [../overlay.md](../overlay.md)）：

- 优先用 `<dialog>` + `showModal()`（支持良好时）获得顶层与 Esc
- `inert` 背景内容（支持时）辅助焦点
- 滚动锁注意 `scrollbar-gutter` 防布局抖

iOS Safari 穿透见 [../hybrid/scroll-lock.md](../hybrid/scroll-lock.md)。
