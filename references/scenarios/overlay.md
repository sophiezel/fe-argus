# L1 — Overlay（弹层 / 滚动穿透 / 焦点）

## 适用信号

Modal、Drawer、ActionSheet、遮罩、滚动穿透、焦点陷阱、Esc 关闭。

---

## 标准解法

### 1. 滚动锁定

打开弹层时锁定背景滚动；关闭后**恢复滚动位置**（记录 `scrollY`，勿只 `overflow:hidden` 导致跳顶）。

```ts
const y = window.scrollY;
document.body.style.position = 'fixed';
document.body.style.top = `-${y}px`;
document.body.style.width = '100%';
// close:
document.body.style.position = '';
document.body.style.top = '';
window.scrollTo(0, y);
```

iOS/WebView 更脆，见 [hybrid/scroll-lock.md](hybrid/scroll-lock.md)。

### 2. 焦点管理

打开 → 焦点移入弹层；关闭 → 回到触发器；Tab 循环困在弹层内（焦点陷阱）。

### 3. 层级与历史

`z-index` 用设计令牌层级；多弹层栈式管理；路由型抽屉考虑 history。

### 4. 关闭手势

遮罩点击 / Esc / 下滑关闭需产品明确；防止误触可要求明确按钮。

---

## 反模式

```css
/* ❌ 只锁 overflow，iOS 仍穿透或关闭后丢滚动位置 */
body.modal-open { overflow: hidden; }
```

```tsx
// ❌ 弹层无焦点管理，读屏与键盘用户困在背景
// ❌ 每个弹层独自监听 body，多实例互相覆盖
```

---

## 环境增量

### Web
- 优先 `<dialog showModal()>`（支持良好时）拿顶层与 Esc
- `inert` 背景（支持时）；`scrollbar-gutter` 防锁滚抖布局

### Hybrid
- 滚动穿透：**MUST** [hybrid/scroll-lock.md](hybrid/scroll-lock.md)

### RN
- 用官方 `Modal` 或导航 present；处理 Android back
- 假弹层勿漏挡触摸（`pointerEvents`）
- Modal 内表单仍要 KeyboardAvoiding（见 [rn/form-keyboard.md](rn/form-keyboard.md)）

## 相关

- [form-input.md](form-input.md)（弹层内表单）
