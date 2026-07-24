# L1 — Device Permission（系统权限）

## 适用信号

相机、相册、定位、麦克风、通知；拒绝后引导；设置页跳转。

---

## 标准解法

### 1. 时机

在用户理解收益的上下文再申请（点「扫码」时），忌启动就弹权限。

### 2. 状态机

`prompt | granted | denied | blocked`；blocked 时引导去系统设置，勿死循环 request。

### 3. 降级

无权限时提供手动输入/选文件等替代路径。

### 4. 文案

说明用途；符合应用商店与隐私合规。

---

## 反模式

```ts
// ❌ App 启动连环申请所有权限
// ❌ denied 后每次 onFocus 再 request → 烦扰/拒审
```

---

## 环境增量

### Hybrid
- 权限多在原生申请；H5 经 bridge 调起，勿假设 `getUserMedia` 可用
- 被拒后「去设置」走原生打开设置页 API

### RN
- `react-native-permissions`（或 Expo）统一 API
- iOS Info.plist / Android manifest 声明缺一不可（商店拒）

### 小程序
- 平台 `authorize` + 隐私协议弹窗（近年强制）
- 拒绝后 `openSetting`；跟厂商审核文案

## 相关

- [media-upload.md](media-upload.md)
