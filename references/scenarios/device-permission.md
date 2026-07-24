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

## L2 指针

- [rn/permission.md](rn/permission.md)
- [miniprogram/permission.md](miniprogram/permission.md)
- [hybrid/permission.md](hybrid/permission.md)

## 相关

- [media-upload.md](media-upload.md)
