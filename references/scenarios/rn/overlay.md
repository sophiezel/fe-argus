# L2 RN — Overlay

增量：

- 用官方 `Modal` 或导航 stack present；注意 Android back
- 背景交互：`pointerEvents`；避免自己用绝对定位假弹层却不挡触摸
- 与键盘同时出现时，Modal 内表单仍要 KeyboardAvoiding
