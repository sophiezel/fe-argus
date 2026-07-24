# L2 Web — Form

增量（相对 [../form-input.md](../form-input.md)）：

- 用原生约束：`required`、`pattern`、`min/max` 作第一道；复杂规则再 JS
- 密码管理器：保持可识别 `autocomplete` 属性
- `enter` 提交：单行 input 默认提交整表，多字段注意拦截

移动浏览器键盘问题以 [../hybrid/form-keyboard.md](../hybrid/form-keyboard.md) 为准（多数 H5 同坑）。
