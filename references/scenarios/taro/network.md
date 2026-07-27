# Taro — 网络层封装

## 适用信号

`Taro.request` / 拦截器 / token 自动刷新 / 多请求共享 loading / 错误码统一处理 / 超时重试 / 取消请求；
多端 API 差异（`wx.request` / `my.request` / `tt.request` / `fetch`）。

---

## 标准解法

### 1. 拦截器链（请求/响应双向）

```ts
// src/api/interceptor.ts
type ReqTransformer = (opts: Taro.request.Option) => Taro.request.Option
type ResTransformer<T> = (res: Taro.request.SuccessCallbackResult<T>) => T

const reqTransformers: ReqTransformer[] = [
  injectBaseUrl,    // 补 baseURL
  injectAuth,       // 注入 Authorization header
  injectTraceId,    // 链路追踪
]
const resTransformers: ResTransformer<any>[] = [
  unwrapEnvelope,   // 解 { code, data, message }
  normalize401,     // 401 自动登出
]

function apply<T>(opts: Taro.request.Option, reqs: ReqTransformer[], ress: ResTransformer<T>[]) {
  const finalOpts = reqs.reduce((acc, fn) => fn(acc), opts)
  return Taro.request<T>(finalOpts).then(res => ress.reduce((v, fn) => fn(res), res as any).data)
}
```

### 2. token 自动刷新（401 单飞）

并发多请求都拿到 401 时，**只刷新一次** token，其余请求排队等：

```ts
let refreshPromise: Promise<string> | null = null

async function refreshToken(): Promise<string> {
  if (refreshPromise) return refreshPromise  // 单飞
  refreshPromise = (async () => {
    try {
      const { token } = await Taro.request<{ token: string }>({
        url: '/auth/refresh', data: { refresh_token: getRefreshToken() }
      })
      setToken(token)
      return token
    } finally {
      refreshPromise = null
    }
  })()
  return refreshPromise
}

// 拦截器：401 时刷新 + 重试一次
async function on401Retry(opts: Taro.request.Option): Promise<any> {
  const newToken = await refreshToken()
  return Taro.request({ ...opts, header: { ...opts.header, Authorization: `Bearer ${newToken}` } })
}
```

**禁止**：每个 401 各自刷新，会导致 refresh_token 被消费多次、服务端吊销。

### 3. loading 计数（多请求共享）

```ts
let loadingCount = 0
let loadingTimer: ReturnType<typeof setTimeout> | null = null

function startLoading() {
  // 200ms 防抖：避免快速请求狂闪
  if (loadingTimer) clearTimeout(loadingTimer)
  loadingTimer = setTimeout(() => Taro.showLoading({ title: '加载中', mask: true }), 200)
  loadingCount++
}
function stopLoading() {
  loadingCount = Math.max(0, loadingCount - 1)
  if (loadingCount === 0) {
    if (loadingTimer) { clearTimeout(loadingTimer); loadingTimer = null }
    Taro.hideLoading()
  }
}
```

**禁止**：每个请求独立 showLoading / hideLoading，并发请求会闪烁 + mask 多层叠加卡死。

### 4. 错误码统一处理

```ts
const ERROR_HANDLERS: Record<number, () => void> = {
  401: () => navigateToLogin(),
  403: () => showToast('无权限'),
  404: () => showToast('资源不存在'),
  429: () => showToast('请求过快，请稍后'),
  500: () => showToast('服务器异常'),
}

// 拦截器：业务码 != 0 视为失败
function unwrapEnvelope(res: Taro.request.SuccessCallbackResult) {
  const body = res.data as { code: number; data: unknown; message: string }
  if (body.code !== 0) {
    ERROR_HANDLERS[body.code]?.()
    throw new ApiError(body.code, body.message)
  }
  return body.data
}
```

### 5. 超时 + 重试（仅幂等请求）

```ts
const IDEMPOTENT = new Set(['GET', 'HEAD', 'OPTIONS'])

async function requestWithRetry(opts: Taro.request.Option, retries = 2): Promise<any> {
  try {
    return await Taro.request({
      timeout: 15000,
      ...opts,
    })
  } catch (err) {
    const isTimeout = (err as Error)?.errMsg?.includes('timeout')
    const isIdempotent = IDEMPOTENT.has((opts.method || 'GET').toUpperCase())
    if (retries > 0 && isTimeout && isIdempotent) {
      await new Promise(r => setTimeout(r, 500 * (3 - retries)))  // 500ms, 1000ms 退避
      return requestWithRetry(opts, retries - 1)
    }
    throw err
  }
}
```

**禁止**：对 POST/PUT/DELETE 自动重试——可能造成重复创建订单。

### 6. 取消请求

Taro.request 不原生支持 AbortController。两种方案：

```ts
// 方案 A：用 Taro.RequestTask（部分端支持）
const task = Taro.request(opts)
task.abort()  // 仅 weapp/alipay 支持

// 方案 B：业务层「弃用标记」（通用）
function makeCancellable() {
  let cancelled = false
  return {
    wrap: <T>(p: Promise<T>) => new Promise<T>((resolve, reject) => {
      p.then(v => cancelled ? reject(new Error('aborted')) : resolve(v))
       .catch(reject)
    }),
    abort: () => { cancelled = true },
  }
}
```

页面卸载时 `useUnMount(() => canceller.abort())`，避免 setState on unmounted。

---

## 多端差异速查

| 维度 | weapp | alipay | tt | h5 |
|---|---|---|---|---|
| 默认超时 | 60s | 30s | 60s | 浏览器默认 |
| 并发上限 | 10 | 10 | 10 | 无限（浏览器 6/host） |
| HTTPS 强制 | ✅ | ✅ | ✅ | 看部署 |
| 域名白名单 | 需在小程序后台配置 | 同 | 同 | 不需要 |
| abort() | RequestTask.abort | RequestTask.abort | RequestTask.abort | AbortController |

**踩坑**：开发环境用 `localhost` 在 weapp 必须勾选「不校验合法域名」；上线必须把所有域名加到小程序后台白名单。

---

## 反模式

```ts
// ❌ 每个请求裸调，没有拦截器
Taro.request({ url: '/api/user', header: { Authorization: getToken() } })

// ❌ 401 不刷新 token，直接报错让用户重登
// ❌ 自动重试 POST 请求（订单可能创建两次）
// ❌ 并发请求各自 showLoading（UI 狂闪 + mask 叠加）
// ❌ Taro.request 不写 timeout（weapp 默认 60s 太长）
// ❌ errCode === 0 当成功（应该是 statusCode === 200）
```

---

## 相关

- 异步韧性通用规则：[async-resilience.md](../async-resilience.md)
- 取消与卸载：[route.md](route.md#页面栈与卸载)
- 拦截器实现参考：[Axios 拦截器架构](https://axios-http.com/docs/interceptors)（Taro 类比）
