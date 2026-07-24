# L2 Miniprogram — List

增量：

- `scroll-view` / `list` / `recyclerview`（视平台）；注意滚动与页面滚动冲突
- 分页用云函数/接口 cursor；下拉 `onPullDownRefresh` 与自定义刷新勿重复绑定
- setData 节流与体积：只更新差分字段（小程序性能核心，见 `../miniprogram-architecture.md`）
