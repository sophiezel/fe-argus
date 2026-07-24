# L2 Hybrid — WebView Bridge

增量（相对 [../webview-bridge.md](../webview-bridge.md)）：

- iOS：`webkit.messageHandlers.xxx.postMessage`
- Android：`javascriptInterface` 或约定 URL scheme；注意线程与返回值异步化
- 注入时机：`DOMContentLoaded` 后仍可能 bridge 未就绪 → 重试队列
- 调试：真机远调；开发者工具与真机行为差参见小程序/WebView 相关 pit

## 相关

- pit-020, pit-021, pit-022
