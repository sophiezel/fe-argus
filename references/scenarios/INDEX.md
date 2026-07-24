# Scenario Playbooks — L0 Index

> **On-demand Hit 入口。** 用任务信号匹配下表 → 只加载命中的 L1（+ 已知环境的 L2）。**禁止**通读本目录。

## 加载协议

1. 扫「信号」列与标签，匹配 1～N 行
2. 读取对应 **L1** 路径
3. 若任务明确 Web / Hybrid(H5/WebView) / RN / 小程序，再读 **L2** 增量
4. 诊断事故时另走 `../pitfalls/INDEX.md`（构建用 playbook，排障用 pit）

## 统一模板（每册）

适用信号 → 标准解法 → 反模式 ❌/✅ → L2 指针 → 相关 pit/coding

---

## 路由表

| 信号（功能 / 症状 / 平台） | L1 | L2（按环境选） | 标签 |
|---------------------------|----|----------------|------|
| 搜索、suggest、即时搜索、拼音、IME、防抖、节流、搜索竞态、乱序响应、骨架屏搜索 | [search.md](search.md) | [web/search.md](web/search.md) · [hybrid/form-keyboard.md](hybrid/form-keyboard.md)（输入相关） · [rn/form-keyboard.md](rn/form-keyboard.md) | `#search` `#ime` `#race` `#debounce` |
| 表单、受控输入、校验、提交幂等、composition | [form-input.md](form-input.md) | [web/form.md](web/form.md) · [hybrid/form-keyboard.md](hybrid/form-keyboard.md) · [rn/form-keyboard.md](rn/form-keyboard.md) · [miniprogram/form.md](miniprogram/form.md) | `#form` `#ime` `#keyboard` |
| 键盘遮挡、visualViewport、KeyboardAvoiding、输入框被挡 | [form-input.md](form-input.md) | [hybrid/form-keyboard.md](hybrid/form-keyboard.md) · [rn/form-keyboard.md](rn/form-keyboard.md) | `#keyboard` |
| 滚动穿透、遮罩滚动、body lock、overscroll | [overlay.md](overlay.md) | [hybrid/scroll-lock.md](hybrid/scroll-lock.md) · [rn/overlay.md](rn/overlay.md) | `#scroll-lock` `#modal` |
| 弹层、Modal、Drawer、ActionSheet、焦点陷阱 | [overlay.md](overlay.md) | [web/overlay.md](web/overlay.md) · [rn/overlay.md](rn/overlay.md) | `#modal` `#a11y` |
| 列表、分页、无限滚动、虚拟列表、下拉刷新、列表竞态 | [list-scroll.md](list-scroll.md) | [web/list.md](web/list.md) · [rn/list.md](rn/list.md) · [miniprogram/list.md](miniprogram/list.md) | `#list` `#virtual` `#race` |
| 上传、选图、压缩、进度、断点 | [media-upload.md](media-upload.md) | [web/upload.md](web/upload.md) · [rn/upload.md](rn/upload.md) · [miniprogram/upload.md](miniprogram/upload.md) | `#upload` |
| WebView、postMessage、JSBridge、Hybrid 通信 | [webview-bridge.md](webview-bridge.md) | [hybrid/webview-bridge.md](hybrid/webview-bridge.md) · [rn/webview.md](rn/webview.md) | `#webview` `#bridge` |
| 弱网、重试、超时、乐观更新回滚 | [async-resilience.md](async-resilience.md) | （通用为主；端差异见各 L2） | `#network` `#retry` |
| 权限、相机、相册、定位、通知授权 | [device-permission.md](device-permission.md) | [rn/permission.md](rn/permission.md) · [miniprogram/permission.md](miniprogram/permission.md) · [hybrid/permission.md](hybrid/permission.md) | `#permission` |
| 深链、回跳、支付回调、OAuth return | [navigation-deeplink.md](navigation-deeplink.md) | [rn/navigation.md](rn/navigation.md) · [hybrid/deeplink.md](hybrid/deeplink.md) · [miniprogram/navigation.md](miniprogram/navigation.md) | `#deeplink` `#payment` |
| Loading、骨架屏、感知性能、空态、错误态 | [loading-ux.md](loading-ux.md) | （与 search/list/form 叠加） | `#loading` `#skeleton` |
| 下拉刷新、上拉加载（与 list 叠加） | [list-scroll.md](list-scroll.md) | [rn/list.md](rn/list.md) · [miniprogram/list.md](miniprogram/list.md) | `#pull-refresh` |

## 环境速查（何时加 L2）

| 环境线索 | 打开目录 |
|----------|----------|
| 浏览器、PC Web、响应式 H5（非容器） | `web/` |
| App WebView、Hybrid、WKWebView、JSBridge | `hybrid/` |
| React Native、Expo | `rn/` |
| 微信/支付宝等小程序 | `miniprogram/` |

## 相关

- Coding Gate：`../../SKILL.md`
- 编码规则：`../coding/`
- 事故复盘：`../pitfalls/INDEX.md`
- 蒸馏队列：[sources.md](sources.md)
