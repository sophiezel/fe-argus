# L2 RN — WebView

增量（相对 [../webview-bridge.md](../webview-bridge.md)）：

- `react-native-webview`：`onMessage` / `injectJavaScript` / `postMessage`
- `originWhitelist`、HTTPS；禁随意 `allowFileAccess`
- 键盘与 WebView：优先在 H5 侧按 hybrid 键盘 playbook；原生与 H5 勿双重 scroll
