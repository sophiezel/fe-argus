# Taro — 多端条件编译

## 适用信号

Taro 项目内分端写代码：微信小程序 / 支付宝小程序 / 抖音小程序 / 百度小程序 / H5 / RN；
`process.env.TARO_ENV`、`Taro.getEnv()`、多端文件后缀、`@tarojs/plugin-platform-*`。

---

## 标准解法

### 1. 静态分支优先（编译时 + tree-shaking）

`process.env.TARO_ENV` 在编译时被静态替换为字符串常量，死分支会被 webpack/vite 删除：

```ts
// ✅ 静态字符串比较 → 编译后死分支被 tree-shake
if (process.env.TARO_ENV === 'weapp') {
  // 仅 weapp 包含这段代码
  wx.login()
} else if (process.env.TARO_ENV === 'h5') {
  window.location.assign('/login')
}
```

**反例**：把 `process.env.TARO_ENV` 装进变量再比较，编译器无法静态替换：

```ts
// ❌ 编译器不知道 platform 是常量，三分支都进 bundle
const platform = process.env.TARO_ENV
if (platform === 'weapp') { ... }
else if (platform === 'h5') { ... }
```

### 2. 文件后缀多端文件

同一段逻辑在不同端实现差异巨大时，用 Taro 多端文件：

```
src/
  api/
    pay.ts           # 默认实现（fallback）
    pay.weapp.ts     # 微信小程序：wx.requestPayment
    pay.alipay.ts    # 支付宝：my.tradePay
    pay.h5.ts        # H5：跳转支付链接
```

Taro 编译时按 `当前端后缀 > 默认` 解析。**禁止**所有端都写一份完整实现，相同部分留在 `pay.ts` 调用即可。

### 3. 运行时判端（最后手段）

`Taro.getEnv()` 运行时返回当前端字符串，**仅**用于：
- 不能静态化的场景（如 SDK 内部运行时判别）
- 调试日志

```ts
// 运行时判端：仅在确实无法静态化时用
import { getEnv } from '@tarojs/taro'
const env = getEnv()  // 'WEAPP' | 'ALIPAY' | 'TT' | 'WEB' | 'RN'
```

注意 `getEnv()` 返回值是**大写**（与 `process.env.TARO_ENV` 的小写不同），不要混用。

### 4. 平台 API 差异速查

| 能力 | 微信 (weapp) | 支付宝 (alipay) | 抖音 (tt) | H5 |
|---|---|---|---|---|
| 登录 | `wx.login` → `Taro.login` | `my.getAuthCode` → `Taro.login`* | `tt.login` → `Taro.login`* | 自研 |
| 支付 | `wx.requestPayment` | `my.tradePay` | `tt.requestPayment` | 跳 H5 链接 |
| 分享 | `onShareAppMessage` | `onShareAppMessage`* | `onShareAppMessage`* | Web Share API |
| 选择图片 | `wx.chooseImage` | `my.chooseImage`* | `tt.chooseImage` | `<input type=file>` |
| 网络请求 | `wx.request` | `my.request` | `tt.request` | `fetch` |

\* Taro 抽象层会统一到 `Taro.xxx`，但部分参数（如支付宝的 `tradePay` 必须传 `tradeNO`）无法对齐，需走多端文件。

---

## 反模式

```ts
// ❌ 运行时大量分支，包体积爆炸
function handleClick() {
  const env = Taro.getEnv()
  if (env === 'WEAPP') {
    import('./wx-pay').then(m => m.default())  // 动态 import 也不能 tree-shake
  } else if (env === 'ALIPAY') {
    ...
  }
  // 6 个端全打进 weapp 包
}

// ❌ 嵌套三元按端渲染
{process.env.TARO_ENV === 'weapp'
  ? <WxButton />
  : process.env.TARO_ENV === 'alipay'
    ? <AlipayButton />
    : <WebButton />}

// ❌ 把 process.env.TARO_ENV 当运行时变量传递
const config = { platform: process.env.TARO_ENV }
// 跨函数后编译器已不能静态追踪
```

```ts
// ✅ 静态分支 + 多端文件
// pay.ts（默认）
export async function pay(orderId: string) {
  const bridge = await loadPayBridge()  // 内部按文件后缀解析
  return bridge(orderId)
}

// pay.weapp.ts
export default async (orderId: string) => {
  const res = await Taro.requestPayment({ timeStamp: ..., packageName: 'wxpay' })
  return res.errMsg === 'requestPayment:ok'
}

// pay.alipay.ts
export default async (orderId: string) => {
  const res = await my.tradePay({ tradeNO: orderId })
  return res.resultCode === '9000'
}
```

---

## 常见踩坑

1. **`process.env.TARO_ENV` 必须用字面量比较**，不能赋值给变量后比较
2. **支付宝的 `tradePay` 不接受 `wx.requestPayment` 同款参数**，必须多端文件
3. **抖音小程序 `tt.login` 不返回 openid**，需要二次请求
4. **H5 没有 `Taro.login`** 等价物，需要自研登录链路
5. **小程序之间组件名相同但 props 不同**（如 `<Button open-type="getUserInfo">` 微信有、支付宝无）

---

## 相关

- 架构层（选型/原理）：`../../cross-platform-architecture.md` §二
- 出事故：`../../pitfalls/pit-057.md`（编译时/运行时不一致）
- 网络层：[network.md](network.md)
- 路由：[route.md](route.md)
- Taro 跨端组件库：`../../cross-platform-architecture.md` §2.4
