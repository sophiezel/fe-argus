# Coding Canon — JS Core

> T2 或触及语言陷阱时读取。蒸馏自常见 JS 书与工程实践（YDKJS 心智模型、可维护子集等）——**可执行规则**，非读书笔记。

## 适用信号

原生 JS/TS 逻辑、异步竞态、类型强制、闭包泄漏；与框架无关。

---

## 1. 相等与空值

**规则：** 默认 `===`；空值合并用 `??`，逻辑默认用 `||` 前先确认会不会吞掉 `0`/`''`。

```ts
// ❌ value || default  // value=0 被替换
// ✅ value ?? default
```

`typeof null === 'object'` —— 判对象用显式 null 检查。

---

## 2. this 与函数形态

**规则：** 需要词法 `this` 用箭头函数；需要动态 `this` / 方法写在对象上用普通函数。class 字段箭头或 constructor bind，保持一致性。

```ts
// ❌ 传入方法时丢 this
button.onClick = obj.handler;

// ✅
button.onClick = () => obj.handler();
// 或 handler = () => { ... } 作为字段
```

---

## 3. 闭包与泄漏

**规则：** 长生命周期闭包（全局监听、缓存、模块单例）不要捕获大对象/DOM；用完释放引用。

相关：pit-003, pit-025。

---

## 4. 异步控制流

**规则：**

| 需求 | 用法 |
|------|------|
| 串行依赖 | `for...of` + `await` |
| 并行 | `Promise.all` |
| 允许部分失败 | `Promise.allSettled` |
| 竞速 | `Promise.race`（慎用） |

**NEVER** `forEach(async () => ...)` 指望等待——见 pit-017。

---

## 5. 竞态与取消

**规则：** 任何「后发可能先至」的异步（输入搜索、tab 切换）必须：

1. `AbortController` 取消，或
2. 单调 `requestId`，响应回写前比对，或
3. 由库（React Query/SWR）按 key 处理

```ts
let seq = 0;
async function load(q: string) {
  const id = ++seq;
  const data = await api.search(q);
  if (id !== seq) return; // 过期
  apply(data);
}
```

---

## 6. 防抖与节流

**规则：**

- **防抖 debounce：** 停输入后再请求（搜索建议）
- **节流 throttle：** 固定频率（scroll、resize）

二者不替代竞态处理——防抖后仍可能乱序，需 Abort/序号。详见 `../scenarios/search.md`。

---

## 7. 不可变与结构共享

**规则：** 更新嵌套对象用展开或成熟库（immer）；禁止对 props/冻结对象 mutate。

---

## 8. 数字与时间

**规则：** 钱用整数分或 decimal 库（pit-015）；时间存 UTC/ISO，展示再本地化（pit-018）。

---

## 9. 模块副作用

**规则：** 模块顶层只放初始化常量与声明；禁止 import 时请求网络或操作 DOM（SSR/测试会炸）。

---

## 10. 可维护子集

**规则：** 优先团队能读懂的清晰代码，而不是炫技：少 with、少奇技淫巧位运算、少隐式转换链。

```ts
// ❌ 炫技难读
const x = ~~n || +!0;

// ✅
const x = Number.isFinite(n) ? Math.trunc(n) : 1;
```

---

## 相关书目与加深

见同目录 `sources.md`。
