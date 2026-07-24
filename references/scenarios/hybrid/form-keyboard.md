# L2 Hybrid — Form & Keyboard

> Q 命中表单/键盘 + Hybrid/WebView 环境时加载。相对 [form-input.md](../form-input.md) / [search.md](../search.md) 的增量。

## 适用信号

App WebView、WKWebView、Android WebView 内 H5；输入框被软键盘挡住；键盘收起后页面留白。

---

## 键盘遮挡（标准解法）

1. `focus` 后延迟 ~300ms（等键盘动画）再 `scrollIntoView({ block: 'center' })`
2. 监听 `visualViewport` `resize`/`scroll`，写入 CSS 变量 `--vvh`；底部 fixed 栏用 `bottom: calc(100vh - var(--vvh))` 或等价定位
3. **NEVER** 用 `100vh` 当「可见高度」（pit-006 / pit-021）
4. 键盘收起后检查 `visualViewport.offsetTop` / 空白，必要时 `window.scrollTo(0, y)` 复位（pit-021）
5. `position:fixed; bottom:0` 底栏在 iOS 常被盖住——改为随 visualViewport 上推或改文档流（pit-027）

```ts
const vv = window.visualViewport;
function syncVvh() {
  document.documentElement.style.setProperty('--vvh', `${vv?.height ?? window.innerHeight}px`);
}
vv?.addEventListener('resize', syncVvh);
vv?.addEventListener('scroll', syncVvh);
```

## 与原生协作

- 原生若已改 WebView frame，H5 **不要**再二次强滚——二选一，否则抖动/双重点
- `readonly` 唤起原生选择器：回填后触发一次受控更新，并关 H5 键盘焦点

## IME

Hybrid 同样有拼音中间态；搜索/校验规则与 L1 相同，**禁止** composition 期间打接口。

## 反模式

```ts
// ❌ 只靠 100vh + fixed 底栏
// ❌ 忽略 composition 做即时搜索
// ❌ 键盘收起不复位，顶部永久空白
```

## 相关

- pit-006, pit-021, pit-027
- [../form-input.md](../form-input.md) · [../search.md](../search.md)
