# L2 Hybrid — Deeplink

增量（相对 [../navigation-deeplink.md](../navigation-deeplink.md)）：

- H5 唤起 App：Universal Link / scheme；失败落落地页
- 回跳进 WebView 时清掉一次性 token query，防分享泄漏
- 与 JSBridge 导航 API 统一，避免 `location` 与原生栈双栈错乱
