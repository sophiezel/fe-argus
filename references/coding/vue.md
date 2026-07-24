# Coding Canon — Vue

> T1+ 且技术栈含 Vue 时必读。事故级细节见 pit-030～034。加深见 [sources.md](sources.md)（场景 R）。

## 适用信号

Vue 3 + Composition API（主路径）；Options API 项目对齐同等原则。

---

## 1. ref / reactive 选择

**规则：** 基本类型与替换整个对象用 `ref`；明确的一组字段可用 `reactive`，但注意解构丢失响应性。

```ts
// ❌ 解构 reactive 丢响应
const { name } = reactive(user); // name 不再是响应式

// ✅
const user = ref({ name: '' });
// 或 toRefs(reactive(user))
```

优先 `ref` 心智更简单，团队一致性更好。

---

## 2. computed 纯净

**规则：** `computed` 只做派生，禁止副作用（请求、改其它 state、DOM）。

```ts
// ❌
const total = computed(() => { fetchTax(); return price * qty; });

// ✅
const total = computed(() => price.value * qty.value);
watch(total, (t) => reportTax(t)); // 副作用放 watch，且谨慎
```

---

## 3. watch 克制

**规则：** 能用 computed 就不用 watch。`watch`/`watchEffect` 必须考虑 `flush` 与清理。

```ts
watch(query, async (q, _p, onCleanup) => {
  const ac = new AbortController();
  onCleanup(() => ac.abort());
  results.value = await search(q, { signal: ac.signal });
});
```

**反模式：** 深层 `watch(() => state, ..., { deep: true })` 无节制 → 性能坑。

---

## 4. 模板与 v-for

**规则：** `v-for` 必须稳定 `:key`；不要用 index（列表会变时）。`v-if` 与 `v-for` 不同节点（Vue 3 已调整优先级，仍建议拆分）。

---

## 5. 组件通信

**规则：** props down / events up；跨层优先 provide/inject 或小 store，避免事件总线（见 `patterns.md` Event Bus 反模式）。

Props 尽量只读；改数据通过 emit 或写权限明确的 store action。

---

## 6. 生命周期清理

**规则：** `onMounted` 注册的监听/定时器在 `onBeforeUnmount` 清理；`watchEffect` 用返回的 stop 或 `onCleanup`。

---

## 7. 大列表与响应式开销

**规则：** 巨大只读表格考虑 `shallowRef` / 非响应式数据 + 局部更新；避免把整表放进 `reactive`。

---

## 8. 脚本组织

**规则：** `<script setup>` 保持薄：复杂逻辑进 `composables/useXxx.ts`；composable 命名 `use` 前缀，返回明确字段。

---

## 9. IME 与输入

**规则：** `@compositionstart` / `@compositionend` 保护搜索/提交；`v-model` 组合期间仍可能触发 input——业务层要判 `isComposing`。

详见 `../scenarios/search.md`。

---

## 10. 请求竞态

与 React 相同：取消或忽略过期响应；优先统一封装在数据层。

---

## NEVER 速查

1. NEVER 在 computed 里发请求
2. NEVER 无清理的 addEventListener / setInterval
3. NEVER 随意 `JSON.parse(JSON.stringify)` 当「深拷贝万能药」处理响应式对象
4. NEVER 在模板写复杂业务分支（抽 computed/方法）
5. NEVER 滥用 `$forceUpdate`
