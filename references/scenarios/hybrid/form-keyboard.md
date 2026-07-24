# L2 Hybrid — Form & Keyboard

增量：App WebView / WKWebView / Android WebView 内 H5 表单。

## 键盘遮挡

1. 聚焦后 `scrollIntoView({ block: 'center' })`（延迟 ~300ms 等键盘动画）
2. 监听 `visualViewport` resize，更新 `--vvh`，底部 fixed 栏用其定位
3. **NEVER** 依赖 `100vh` 作为可视高度（pit-006 / pit-021）
4. 键盘收起后检查页面是否留白，必要时 `scrollTo` 复位（pit-021）

## 与原生协作

- 部分 App 用原生调整 WebView frame——与 H5 自滚动**二选一**，避免双重点
- `input` `readonly` 唤起原生选择器时，注意焦点与回填

## 反模式

```ts
// ❌ position:fixed; bottom:0 底栏在 iOS 被键盘盖住且无适配（pit-027）
// ❌ 忽略 composition，Hybrid 中文输入同样会出拼音中间态搜索
```

## 相关

- pit-021, pit-027, pit-006
- [../form-input.md](../form-input.md) · [../search.md](../search.md)
