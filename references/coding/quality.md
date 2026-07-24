# Coding Canon — Quality（简洁 / 健壮 / 抽象）

> T1+ 默认必读。架构选型见 `patterns.md` / `decisions.md`。加深队列见 [sources.md](sources.md)（场景 R）。

## 适用信号

任意写/改前端代码。

---

## 1. YAGNI / 最小改动

只实现当前需求证明需要的行为；不为假想扩展加配置/分支。

```ts
// ❌ fetchUser(id, { cache, retry, timeout, transform })
// ✅ fetchUser(id: string): Promise<User>
```

**边界：** 需求已写明的扩展点可留；猜测的不行。对齐仓库 `minimal-fix-first` 心智。

---

## 2. 抽象频率

同类逻辑真实出现 **≥2 处** 再抽；一处内联。抽象后 diff 不得大于局部修复。

**边界：** 跨包公共契约、设计系统组件是产品边界，不是「提前抽」。

---

## 3. 命名达意

| ❌ | ✅ |
|----|----|
| `data` / `info` / `temp` | `orderList` / `previousCursor` |
| `flag` / `handleClick1` | `isCheckoutReady` / `onSubmitOrder` |

布尔 `is|has|can|should`；事件 `on` + 事件名。

---

## 4. 体量与职责

函数单一职责（优先 <50 行）；文件触顶先拆（God Component 见 `patterns.md`）。请求 / 表单 / 列表 / 埋点勿堆同一文件。

---

## 5. 不可变更新

禁止原地 mutate；返回新引用（便于 React/Vue 变更检测）。

```ts
// ❌ state.items.push(x)
// ✅ { ...state, items: [...state.items, x] }
```

---

## 6. 边界校验与失败可见

用户输入 / API / 存储入口校验；**NEVER** 空 `catch`。UI 给人话，日志给排障（脱敏）。

---

## 7. 依赖方向

页面不散落裸 `fetch` URL / 私建传输层；走项目既有 `api/`、hooks 边界。

---

## 写前自检

```
□ 更少文件/抽象能否完成？
□ diff 是否仅任务所需？
□ 命名 5 秒可读？
□ 空值/失败路径是否可见？
□ 是否加了未要求的「灵活性」？
```

## 相关

- `patterns.md` 第六节 · `checklist.md` · `../pitfalls/`（诊断时）
