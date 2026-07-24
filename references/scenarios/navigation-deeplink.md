# L1 — Navigation & Deeplink（深链 / 回跳）

## 适用信号

Universal Link / App Link、scheme、支付/OAuth 回跳、冷热启动参数、小程序场景值。

---

## 标准解法

### 1. 单一解析入口

集中 parse → 校验 → 导航；防开放重定向（白名单域名/path）。

### 2. 冷热启动

冷启动：等导航树 ready 再 navigate；热启动：合并入站事件，防丢。

### 3. 回跳幂等

支付回调可能多次；以订单状态机为准，UI 可重复进入结果页但副作用只一次。

### 4. 降级

无 App → H5；无权限 → 中间页说明。

---

## 反模式

```ts
// ❌ 信任 deeplink 任意 url 直接 WebView.open
// ❌ 回跳多次 createOrder
```

---

## L2 指针

- [rn/navigation.md](rn/navigation.md)
- [hybrid/deeplink.md](hybrid/deeplink.md)
- [miniprogram/navigation.md](miniprogram/navigation.md)

## 相关

- [webview-bridge.md](webview-bridge.md)
- [async-resilience.md](async-resilience.md)
