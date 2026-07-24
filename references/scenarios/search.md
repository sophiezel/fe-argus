# L1 — Search（搜索 / 即时建议）

## 适用信号

搜索框、suggest、联想词、过滤器即时查询；拼音 IME；防抖/节流；结果错乱；加载态。

---

## 标准解法

### 1. IME：组合完成前不触发搜索

中文等输入法在 `composition` 期间 `input` 事件会带出拼音中间态——**禁止**用中间态打接口。

```ts
let composing = false;
input.addEventListener('compositionstart', () => { composing = true; });
input.addEventListener('compositionend', (e) => {
  composing = false;
  scheduleSearch((e.target as HTMLInputElement).value);
});
input.addEventListener('input', (e) => {
  if (composing) return;
  scheduleSearch((e.target as HTMLInputElement).value);
});
```

React：`onCompositionStart/End` + `isComposing`；注意部分浏览器 `compositionend` 后再发一次 `input`。

### 2. 请求与关键字幂等（防乱序）

后发出的请求可能先返回。必须忽略过期响应：

```ts
// 方案 A：AbortController（推荐）
let ac: AbortController | null = null;
function search(q: string) {
  ac?.abort();
  ac = new AbortController();
  return api.search(q, { signal: ac.signal });
}

// 方案 B：单调序号
let seq = 0;
async function search(q: string) {
  const id = ++seq;
  const data = await api.search(q);
  if (id !== seq) return null;
  return data;
}
```

库方案：React Query / SWR 以 `queryKey` 绑定 UI，自动丢掉过期数据。

### 3. 防抖 / 节流

| 模式 | 用途 | 典型 |
|------|------|------|
| debounce | 停止输入后再请求 | 建议 200–400ms |
| throttle | 滚动联动筛选 | 100–200ms |

**防抖不替代竞态处理**：debounce 后仍可能重叠请求（慢网），必须保留 Abort/序号。

### 4. Loading / 骨架 / 空态

按产品交互选，避免「狂闪 loading」：

| 场景 | 建议 |
|------|------|
| 首搜无缓存 | 骨架或局部 spinner |
| 同关键词刷新 | 静默或保留旧结果 + 顶部细进度 |
| 空串 | 清结果或展示热词，勿发无效请求 |
| 错误 | 可重试错误态，勿空白 |

与 [loading-ux.md](loading-ux.md) 叠加。

### 5. 取消与卸载

组件卸载时 abort；路由离开时清空过期回调。

---

## 反模式

```ts
// ❌ 每个 onChange 直接 fetch，无 IME、无取消
onChange={(e) => fetch('/s?q=' + e.target.value).then(setList)}

// ❌ 只防抖不处理乱序
onChange={debounce((v) => fetch(v).then(setList), 300)}

// ❌ 用拼音中间态搜：composition 期间 setQuery 并立刻请求

// ✅ IME 门闸 + debounce + Abort + 合理 loading
```

---

## 环境增量

### Web
- 桌面：`input[type=search]`；快捷键 `/` 聚焦时勿与浏览器查找冲突
- Safari：`composition` 顺序与 Chrome 略异，以 `compositionend` 为准再搜
- History：仅在提交或 debounce 稳定后 `replaceState` 写 q，避免污染历史

### Hybrid / RN（键盘与输入容器）
- 叠加 [hybrid/form-keyboard.md](hybrid/form-keyboard.md) / [rn/form-keyboard.md](rn/form-keyboard.md)
- RN 无 DOM composition：搜索勿每个 `onChangeText` 立即请求，debounce + 结束编辑再搜

## 相关

- `../coding/react.md` §请求竞态 · `../coding/js-core.md` §竞态
- pit-005（竞态验证）
- `../ai-frontend-patterns.md` IME Composer 示例
