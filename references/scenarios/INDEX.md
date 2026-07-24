# Scenario Playbooks — L0 Index

> **On-demand Hit 入口。** 匹配下表 → 只加载命中的 L1（+ 仍存在的 L2）。**禁止**通读本目录。  
> 加深/蒸馏队列见 [sources.md](sources.md)（场景 R）。

## 加载协议

1. 扫「信号」列，匹配 1～N 行  
2. 读对应 **L1**（含文内「环境增量」小节）  
3. 仅当任务明确 Hybrid/RN **且**下表 L2 列有路径时，再读该 L2  
4. 诊断事故走 `../pitfalls/INDEX.md`

## 路由表

| 信号 | L1 | L2（仅高价值差分） | 标签 |
|------|----|-------------------|------|
| 搜索、suggest、拼音、IME、防抖、节流、搜索竞态、乱序 | [search.md](search.md) | 键盘容器：[hybrid/form-keyboard.md](hybrid/form-keyboard.md) · [rn/form-keyboard.md](rn/form-keyboard.md) | `#search` `#ime` `#race` |
| 表单、校验、提交幂等、composition | [form-input.md](form-input.md) | [hybrid/form-keyboard.md](hybrid/form-keyboard.md) · [rn/form-keyboard.md](rn/form-keyboard.md) | `#form` `#keyboard` |
| 键盘遮挡、visualViewport、KeyboardAvoiding | [form-input.md](form-input.md) | [hybrid/form-keyboard.md](hybrid/form-keyboard.md) · [rn/form-keyboard.md](rn/form-keyboard.md) | `#keyboard` |
| 滚动穿透、body lock、overscroll | [overlay.md](overlay.md) | [hybrid/scroll-lock.md](hybrid/scroll-lock.md) | `#scroll-lock` |
| 弹层、Modal、Drawer、焦点陷阱 | [overlay.md](overlay.md) | （Web/RN 增量在 L1「环境增量」） | `#modal` |
| 列表、分页、虚拟列表、下拉刷新 | [list-scroll.md](list-scroll.md) | [rn/list.md](rn/list.md) | `#list` `#virtual` |
| 上传、选图、压缩、进度 | [media-upload.md](media-upload.md) | （环境增量在 L1） | `#upload` |
| WebView、postMessage、JSBridge | [webview-bridge.md](webview-bridge.md) | [hybrid/webview-bridge.md](hybrid/webview-bridge.md) | `#webview` `#bridge` |
| 弱网、重试、超时、乐观更新 | [async-resilience.md](async-resilience.md) | — | `#network` |
| 权限、相机、相册、定位 | [device-permission.md](device-permission.md) | （环境增量在 L1） | `#permission` |
| 深链、支付/OAuth 回跳 | [navigation-deeplink.md](navigation-deeplink.md) | （环境增量在 L1） | `#deeplink` |
| Loading、骨架、空态、错误态 | [loading-ux.md](loading-ux.md) | — | `#loading` |

## 环境速查

| 线索 | 动作 |
|------|------|
| 纯 Web | 读 L1「环境增量 → Web」即可 |
| Hybrid / WebView | L1 + 上表 Hybrid L2（若有） |
| React Native | L1 + 上表 RN L2（若有） |
| 小程序 | 读 L1「环境增量 → 小程序」 |

## 相关

- Coding Gate：`../../SKILL.md`（场景 Q / R）
- `../coding/` · `../pitfalls/INDEX.md`
- [sources.md](sources.md)
