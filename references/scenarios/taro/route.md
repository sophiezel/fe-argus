# Taro — 路由与页面栈

## 适用信号

`Taro.navigateTo` / `redirectTo` / `switchTab` / `reLaunch` / `navigateBack`；
页面栈 10 层限制；TabBar 配置；防止用户连点导致栈爆炸；路由参数序列化。

---

## 标准解法

### 1. 五种跳转 API 选型

| API | 行为 | 适用 |
|---|---|---|
| `Taro.navigateTo` | 推入栈，保留当前页（栈深度 +1） | 普通详情页跳转 |
| `Taro.redirectTo` | 替换当前页（栈深度不变） | 登录后跳首页、表单提交后跳结果 |
| `Taro.reLaunch` | 清空整个栈，重启到目标页 | 退出登录、深链冷启动 |
| `Taro.switchTab` | 切到 TabBar 页（清空非 Tab 页栈） | Tab 之间切换 |
| `Taro.navigateBack` | 出栈（栈深度 -N） | 返回上一页 / 多级返回 |

**口诀**：navigateTo 加深、redirectTo 替换、reLaunch 清空、switchTab 切 Tab。

### 2. 页面栈 10 层保护

小程序页面栈上限 **10 层**（含 TabBar 页）。超出 `navigateTo` 会失败。常见原因：用户连点、循环跳转、列表 → 详情 → 列表 → 详情…

```ts
// 封装：自动检测栈深度
export function safeNavigateTo(url: string) {
  const pages = Taro.getCurrentPages()
  if (pages.length >= 9) {
    // 接近上限：用 redirectTo 替换当前页，避免爆栈
    return Taro.redirectTo({ url })
  }
  return Taro.navigateTo({ url })
}
```

更彻底的方案：列表 → 详情 用 redirectTo 而不是 navigateTo（如果用户不需要"返回列表"），或详情页之间互相 redirectTo。

### 3. 防抖（防止用户连点）

连点 0.5s 内多次 `navigateTo` 会推入多个相同页面：

```ts
let lastNav = 0
export function safeNavigateTo(url: string) {
  const now = Date.now()
  if (now - lastNav < 500) return  // 500ms 内重复忽略
  lastNav = now
  return Taro.navigateTo({ url })
}
```

**禁止**：在按钮 onClick 里裸调 `Taro.navigateTo`，用户快速双击会跳两次。

### 4. 路由参数序列化

URL query 只接受字符串。复杂参数（对象/数组）必须序列化：

```ts
// ✅ 简单参数直接拼
Taro.navigateTo({ url: `/pages/detail/index?id=${id}&from=list` })

// ✅ 复杂参数 JSON 化 + encodeURIComponent
const filter = { category: 'book', tags: ['new', 'hot'], page: 1 }
Taro.navigateTo({
  url: `/pages/list/index?filter=${encodeURIComponent(JSON.stringify(filter))}`,
})

// 接收方
const { filter } = Taro.getCurrentInstance().router?.params || {}
const parsed = filter ? JSON.parse(decodeURIComponent(filter)) : null
```

**禁止**：直接传对象（`url?filter=${filter}` → `[object Object]`）；不要传太长（小程序 URL 限制 ~1KB）。

### 5. TabBar 配置

```ts
// src/app.config.ts
export default {
  tabBar: {
    list: [
      { pagePath: 'pages/index/index', text: '首页' },
      { pagePath: 'pages/cart/index', text: '购物车' },
      { pagePath: 'pages/me/index', text: '我的' },
    ],
  },
}
```

**关键约束**：
- TabBar 页**必须**用 `switchTab` 跳，用 `navigateTo` 会失败
- TabBar 最多 5 个
- TabBar 页之间不会销毁，state 保留（小心内存泄漏）

### 6. 页面卸载清理

```tsx
function DetailPage() {
  const requestTask = useRef<Taro.RequestTask | null>(null)

  useEffect(() => {
    requestTask.current = Taro.request({ url: '/api/detail' })
    return () => {
      // 卸载时取消请求，避免 setState on unmounted
      requestTask.current?.abort()
    }
  }, [])

  // 小程序专属：onUnload 兜底（部分场景 useEffect cleanup 来不及）
  useDidHide(() => {
    requestTask.current?.abort()
  })
}
```

---

## 反模式

```ts
// ❌ 在 onClick 裸调 navigateTo（连点会爆栈）
<Button onClick={() => Taro.navigateTo({ url: '/pages/detail' })}>详情</Button>

// ❌ 列表 → 详情 → 列表 → 详情（栈不断加深）
// 解决：详情页返回用 navigateBack，或列表用 redirectTo 进入详情

// ❌ 用 navigateTo 切 TabBar 页（会失败）
// ❌ 路由参数直接传对象
// ❌ 退出登录用 navigateTo（应该 reLaunch 清栈，否则用户按返回还能回到登录后的页面）
// ❌ 长参数超过 1KB
// ❌ TabBar 页 useEffect 不清理（页面常驻，泄漏累积）
```

---

## 多端差异

| 行为 | weapp | alipay | tt | h5 |
|---|---|---|---|---|
| 页面栈上限 | 10 | 10 | 10 | 浏览器 history 无限 |
| TabBar 切换动画 | 默认 | 默认 | 默认 | 取决于 UI 库 |
| `getCurrentPages` | ✅ | ✅ | ✅ | Taro 模拟 |
| 路由参数长度限制 | ~1KB | ~1KB | ~1KB | URL 长度限制（2KB~8KB） |
| `navigateBack` delta | 1-10 | 1-10 | 1-10 | history.go(-N) |

---

## 相关

- 网络层取消：[network.md](network.md#取消请求)
- 跨端方案层：`../../cross-platform-architecture.md` §二
- Taro 出事故：`../../pitfalls/pit-057.md`
