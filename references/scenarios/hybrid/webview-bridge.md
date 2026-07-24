# L2 Hybrid — WebView Bridge

> Q 命中桥通信 + Hybrid 时加载。相对 [webview-bridge.md](../webview-bridge.md)。

## 适用信号

iOS `webkit.messageHandlers`、Android JavascriptInterface / URL scheme；桥未就绪白屏。

---

## 平台差异

| 平台 | 常见注入 | 注意 |
|------|----------|------|
| iOS WKWebView | `window.webkit.messageHandlers.xxx.postMessage` | 消息体可序列化；大 payload 拆包 |
| Android | `@JavascriptInterface` 或自定义 scheme | 回调常在非 UI 线程，回 H5 要切线程 |
| 双方 | 约定 `requestId` + timeout | unload 清 pending |

## 就绪与重试

- `DOMContentLoaded` 后桥仍可能未注入 → **探测 ping** + 短队列重试（上限次数）
- 旧版 App：能力探测失败则降级 UI，勿假设方法存在

## 安全

- 校验来源；最小 API 面；敏感操作在原生二次确认
- **NEVER** `eval` 入站消息（pit-020）

## 反模式

```js
// ❌ 假设 bridge 永远同步可用
// ❌ Android interface 直接返回复杂对象且不文档化线程
```

## 相关

- pit-020, pit-021, pit-022
- [../webview-bridge.md](../webview-bridge.md)
