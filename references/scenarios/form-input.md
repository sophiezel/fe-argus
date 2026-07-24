# L1 — Form Input（表单 / 输入）

## 适用信号

登录注册、多字段表单、受控输入、校验时机、提交、IME、键盘遮挡（Hybrid/RN 见专用 L2）。

---

## 标准解法

### 1. 受控 vs 非受控

- 需要即时校验/联动 → 受控
- 简单原生提交、无中间态 → 可非受控 / FormData
- 混合时明确边界，避免「半受控」警告

### 2. 校验时机

| 策略 | 何时 |
|------|------|
| submit 时 | 默认；减少打扰 |
| blur 时 | 字段离开 |
| change 时 | 强约束格式（验证码）且已处理 IME |

IME 组合期间不做「格式错误」红字（与搜索同样门闸）。

### 3. 提交幂等

- 提交中禁用按钮 / 忽略重复 click
- 客户端 requestId 或服务端幂等键
- 失败可重试时恢复可点；成功则防二次提交

### 4. 错误展示

字段级错误贴字段；表单级错误置顶；网络错误可重试。不要只 `console.log`。

### 5. 无障碍

`label` 关联、`aria-invalid`、错误文案 `aria-describedby`；不要仅靠颜色。

---

## 反模式

```tsx
// ❌ 提交无防抖/无 loading，连点创建多单
<button onClick={() => createOrder()}>提交</button>

// ❌ 每个 keydown 都跑全量异步校验（含 IME 中间态）

// ✅
const [pending, setPending] = useState(false);
async function onSubmit() {
  if (pending) return;
  setPending(true);
  try { await createOrder(payload); }
  finally { setPending(false); }
}
```

---

## 环境增量

### Web
- 原生约束先用 `required` / `pattern` / `min|max`；复杂规则再 JS
- 保持可识别 `autocomplete`（密码管理器）
- 单行 Enter 会提交整表，多字段注意拦截

### Hybrid
- 键盘遮挡 / visualViewport：**MUST** [hybrid/form-keyboard.md](hybrid/form-keyboard.md)

### RN
- KeyboardAvoiding：**MUST** [rn/form-keyboard.md](rn/form-keyboard.md)

### 小程序
- `bindinput` / `bindblur`；搜索 `confirm-type`
- 键盘：`adjust-position`、`hold-keyboard`；真机验遮挡
- `button form-type` 提交；loading 防连点

## 相关

- pit-021 / pit-027（键盘）
- [search.md](search.md) IME
- [loading-ux.md](loading-ux.md)
