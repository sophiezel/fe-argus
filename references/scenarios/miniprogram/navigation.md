# L2 Miniprogram — Navigation

增量：

- 页面栈 10 层限制；慎用 `navigateTo` 过深，适时 `redirectTo`/`reLaunch`
- 场景值与 `query` 解析集中处理
- 与支付回跳：`onShow` 幂等查单
