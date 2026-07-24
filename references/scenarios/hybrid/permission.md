# L2 Hybrid — Permission

增量：权限多在**原生**申请；H5 经 bridge 调起。

- H5 不假设 `getUserMedia` 在 WebView 可用
- 被拒后展示「去设置」走原生打开设置页 API
- 对齐 [../device-permission.md](../device-permission.md) 状态机
