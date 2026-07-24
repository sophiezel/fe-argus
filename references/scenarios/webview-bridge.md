# L1 — WebView Bridge（容器通信）

## 适用信号

App 内 H5、JSBridge、`postMessage`、RN WebView、协议约定、版本兼容。

---

## 标准解法

### 1. 契约先行

消息：`{ type, payload, requestId, version }`；未知 `type` 忽略并打日志；破坏性变更升 version。

### 2. 方向与源校验

`window.addEventListener('message')` 校验 `origin` / 约定 source；RN 用 `onMessage` + 注入脚本对称。

### 3. 调用生命周期

H5 调原生：超时、取消、页面 unload 清理 pending map（按 requestId）。

### 4. 能力探测

先 `ping` / `getEnv` 再调相机等；旧 App 降级 UI。

### 5. 安全

勿对不可信内容 `eval`；桥接 API 最小权限；敏感操作用户确认在原生侧。

---

## 反模式

```js
// ❌ 任意 message 直接 eval / 改 location
// ❌ 无 requestId，回调串台
// ❌ 假设桥永远存在，旧版白屏
```

---

## L2 指针

- [hybrid/webview-bridge.md](hybrid/webview-bridge.md)
- [rn/webview.md](rn/webview.md)

## 相关

- pit-020（WebView postMessage）
- [navigation-deeplink.md](navigation-deeplink.md)
