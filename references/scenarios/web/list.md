# L2 Web — List

增量（相对 [../list-scroll.md](../list-scroll.md)）：

- `IntersectionObserver` 做无限滚动，根 margin 预加载
- 虚拟列表可选 `@tanstack/virtual` 等；SSR 注意仅客户端挂载
- `content-visibility: auto` 可作轻量优化，不替代虚拟列表
