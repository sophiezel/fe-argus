# Coding Canon — React

> T1+ 且技术栈含 React 时必读。事故级细节见 `pitfalls/`（如 pit-001～005）。

## 适用信号

React / React Native（共享 hooks 心智）/ Next.js 客户端组件。

---

## 1. Effects 不是事件处理器

**规则：** 用户动作（点击、提交）放事件处理器；`useEffect` 只同步「React 外部系统」。

```tsx
// ❌ 用 effect 响应点击间接流
useEffect(() => { if (submitted) post(data); }, [submitted]);

// ✅
async function onSubmit() { await post(data); }
```

相关：`patterns.md` useEffect 地狱；pit-001。

---

## 2. 依赖与稳定引用

**规则：** effect/memo 依赖必须完整；禁止在依赖中放每次渲染新建的对象/数组/内联函数（除非有意）。

```tsx
// ❌ 死循环风险
useEffect(() => { load(filters); }, [{ ...filters }]);

// ✅ 原始值或稳定序列化 / 外提常量
useEffect(() => { load(filters); }, [filters.status, filters.page]);
```

`useCallback`/`useMemo` **仅**在作为子组件 props 或其它 hook 依赖且已测量需要时使用——默认不加。

---

## 3. 列表 key

**规则：** 稳定业务 id 作 key；禁止用 index（列表会重排/插入/删除时）。

```tsx
// ❌ key={index}
// ✅ key={item.id}
```

---

## 4. 派生状态

**规则：** 能从 props/state 算出的不要再存一份 state（易不同步）。

```tsx
// ❌
const [items, setItems] = useState(props.items);
const [count, setCount] = useState(props.items.length);

// ✅
const count = items.length;
```

---

## 5. 请求竞态

**规则：** 快速变更的查询必须忽略过期响应（AbortController、请求序号、或 React Query/SWR key）。

```tsx
useEffect(() => {
  const ac = new AbortController();
  let alive = true;
  search(q, { signal: ac.signal }).then((r) => { if (alive) setRows(r); });
  return () => { alive = false; ac.abort(); };
}, [q]);
```

详见 Scenario Playbook `../scenarios/search.md`；pit-005。

---

## 6. 清理订阅

**规则：** 订阅、timer、WebSocket、IntersectionObserver 必须在 effect cleanup 释放。

```tsx
useEffect(() => {
  const id = setInterval(tick, 1000);
  return () => clearInterval(id);
}, []);
```

相关：pit-025, pit-026。

---

## 7. 重渲染控制（克制）

| 做法 | 何时 |
|------|------|
| 下推 state | 高频更新只影响局部子树 |
| 拆分 Context | state 与 dispatch 分离 |
| `memo` | 重子树 + 稳定 props，先测再加 |
| 虚拟列表 | 长列表 Dom 过多 |

**反模式：** 到处 `React.memo` + 盲目 `useCallback` 造成噪音、无收益。

---

## 8. 并发与过渡（React 18+）

**规则：** 可中断的非紧急更新用 `startTransition` / `useDeferredValue`；紧急输入保持同步。

```tsx
const [query, setQuery] = useState('');
const deferred = useDeferredValue(query);
// 输入框绑 query；结果列表绑 deferred
```

---

## 9. Server Components 边界（Next）

**规则：** 默认服务端；需要 hooks/浏览器 API 才标 `'use client'`。Client 边界尽量靠叶节点，避免整页 client。

---

## 10. 受控输入与 IME

**规则：** 中文等 IME 组合期间不要把中间拼音当成提交/搜索关键字；监听 `compositionstart/end`。

详见 `../scenarios/search.md`、`../scenarios/form-input.md`。

---

## NEVER 速查

1. NEVER 在 render 里发起请求或写 localStorage
2. NEVER 把 hook 放进条件/循环
3. NEVER 用 useEffect 把 props 镜像成 state「以防万一」
4. NEVER 忘记列表/动画组件卸载清理
5. NEVER 在依赖数组里撒谎（eslint-disable react-hooks/exhaustive-deps 需书面理由）
