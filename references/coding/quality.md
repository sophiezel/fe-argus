# Coding Canon — Quality (简洁 / 健壮 / 抽象)

> T1+ 默认必读。写业务代码时的质量底线。架构选型见 `patterns.md` / `decisions.md`。

## 适用信号

任意写/改前端代码；与框架无关。

---

## 1. YAGNI / 最小改动

**规则：** 只实现当前需求证明需要的行为；不为「以后可能」加分支、配置、抽象。

```ts
// ❌ 假想扩展
function fetchUser(id: string, opts?: { cache?: boolean; retry?: number; timeout?: number; transform?: Fn }) { /* ... */ }

// ✅ 当前只需取用户
async function fetchUser(id: string): Promise<User> {
  return api.get(`/users/${id}`);
}
```

**边界：** 需求已明确列出的扩展点可以预留；猜测的不行。

---

## 2. 抽象阈值

**规则：** 同类逻辑真实出现 **≥2 处** 再抽象；一处保持内联。抽象后改动面不得大于局部修复。

```ts
// ❌ 只用一次就抽 utils
export const formatPrice = (n: number) => `¥${n.toFixed(2)}`;
// 调用点仅一处

// ✅ 先内联；第二处出现再抽
<span>{`¥${price.toFixed(2)}`}</span>
```

**边界：** 跨包公共契约、设计系统组件除外——那些是产品边界，不是「提前抽」。

---

## 3. 命名达意

**规则：** 名称表达业务含义与单位；禁模糊名。

| ❌ | ✅ |
|----|----|
| `data` / `info` / `obj` | `orderList` / `paymentReceipt` |
| `flag` / `temp` | `isCheckoutReady` / `previousCursor` |
| `handleClick1` | `onSubmitOrder` |
| `d` / `t` | `delayMs` / `createdAt` |

布尔用 `is/has/can/should`；函数用动词短语；事件处理器用 `on` + 事件。

---

## 4. 函数与文件体量

**规则：** 单函数保持单一职责，优先 <50 行；单文件高内聚，典型 200–400 行，触顶先拆而非继续堆。

```tsx
// ❌ God Component：请求+表单+列表+埋点全在一文件 800 行

// ✅ 按职责拆：OrderForm / useOrderSubmit / orderApi
```

---

## 5. 不可变更新

**规则：** 不原地 mutate；返回新引用。便于调试与 React/Vue 变更检测。

```ts
// ❌
state.items.push(item); state.user.name = name;

// ✅
return { ...state, items: [...state.items, item], user: { ...state.user, name } };
```

---

## 6. 边界校验与失败可见

**规则：** 在系统边界（用户输入、API、存储）校验；失败要可观察（UI 提示或日志），禁止吞错。

```ts
// ❌
try { await save(data); } catch (e) {}

// ✅
try {
  await save(parseOrderInput(data));
} catch (e) {
  logger.error('save_order_failed', { e });
  toast.error('保存失败，请重试');
}
```

---

## 7. 错误处理分层

| 层 | 做什么 |
|----|--------|
| UI | 用户可读文案、可恢复动作 |
| 领域/Hook | 归一化错误类型、重试策略 |
| 基础设施 | 日志、监控、脱敏 |

禁止把 raw HTTP 错误字符串直接甩给用户。

---

## 8. 依赖方向

**规则：** 业务/UI 不直接依赖基础设施细节；通过已有项目边界（api 模块、hooks）访问。

```ts
// ❌ 页面里 new XMLHttpRequest / 散落 fetch URL 字符串

// ✅ 走项目既有 api/order.ts
```

---

## 9. 注释与死代码

**规则：** 注释解释「为什么」；删掉注释掉的代码块（git 可追溯）。禁止用注释代替清晰命名。

---

## 10. 写前自检（30 秒）

```
□ 能否用更少文件/更少抽象完成？
□ 是否只改了任务相关行？
□ 命名能否让陌生同事 5 秒看懂？
□ 空值/失败路径是否处理？
□ 是否引入了未要求的「灵活性」？
```

## 相关

- 架构反模式：`../patterns.md` 第六节
- 提交清单：`../checklist.md`
- 事故复盘：`../pitfalls/`（诊断时读，不替代本 canon）
