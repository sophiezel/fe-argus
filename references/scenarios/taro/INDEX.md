# Taro Scenario Playbooks — L0 Index

> Taro 跨端框架专属场景。命中后只加载对应 playbook。**禁止**通读本目录。

## 何时读本 INDEX

满足以下任一信号：
- 项目 `package.json` 含 `@tarojs/cli` / `@tarojs/taro` / `@tarojs/components`
- 用户提到 Taro / 多端编译 / 微信小程序 / 支付宝小程序 / 抖音小程序
- `process.env.TARO_ENV` 出现在代码或配置里

---

## 路由表

| 信号 | Playbook |
|---|---|
| 条件编译、`process.env.TARO_ENV`、`Taro.getEnv`、多端文件后缀、平台 API 差异 | [multi-platform.md](multi-platform.md) |
| `Taro.request`、拦截器、token 刷新、loading、错误码、超时重试 | [network.md](network.md) |
| `navigateTo` / `redirectTo` / `switchTab` / `reLaunch`、页面栈、TabBar、路由参数 | [route.md](route.md) |

---

## 与其他文档的边界

| 任务 | 读什么 |
|---|---|
| 写代码前（场景 Q） | 本 INDEX → 命中 playbook |
| Taro 跨端框架**选型**决策 | `../../cross-platform-architecture.md` §二（不读本目录） |
| Taro 项目出事故 | `../../pitfalls/pit-057.md`（编译时/运行时不一致） |
| 跨端通用兼容矩阵 | `../../compatibility-matrix.md` |

---

## 平台覆盖

playbook 内的多端差异表覆盖以下端：

- **weapp** — 微信小程序
- **alipay** — 支付宝小程序
- **tt** — 抖音小程序
- **bd** — 百度小程序（部分场景列入）
- **h5** — Web
- **rn** — React Native（Taro RN 走 RN 通路，本目录仅注差异）

注意：H5 在 Taro 里走 webpack/vite 打包，与原生 Web 项目无本质差异——通用场景（搜索/表单/列表）走 [`../search.md`](../search.md) 等 L1 playbook 即可，本目录只覆盖 Taro 特有的多端编译层问题。
