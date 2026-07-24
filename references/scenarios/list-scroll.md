# L1 — List & Scroll（列表 / 分页 / 虚拟列表）

## 适用信号

分页、无限滚动、虚拟列表、下拉刷新、上拉加载、列表请求竞态、白屏闪烁。

---

## 标准解法

### 1. 分页模型

明确：页码分页 vs cursor；刷新重置 cursor；加载更多追加且去重（按 id）。

### 2. 竞态

快速切换筛选/tab：abort 或序号；**禁止**旧页数据追加到新筛选结果。

### 3. 虚拟列表

长列表（数百+）用虚拟化；固定/估算行高；动态行高需测量缓存。注意焦点与无障碍（可见窗口外节点）。

### 4. 下拉刷新 / 上拉加载

- 刷新中忽略重复手势
- 底部加载用独立 `loadingMore`，勿与首屏 `loading` 混用导致整表被 skeleton 替换
- 空态与「没有更多」文案区分

### 5. Key 与回收

稳定 id；虚拟列表回收行时注意输入态丢失（编辑中的行勿粗暴回收）。

---

## 反模式

```ts
// ❌ 筛选变化时把旧请求结果 concat 进 list
// ❌ 每页 loading 都卸载整个列表 → 闪烁
// ❌ key={index} 且分页插入删除
```

---

## 环境增量

### Web
- `IntersectionObserver` 无限滚动，根 margin 预加载
- 虚拟列表（如 TanStack Virtual）；SSR 仅客户端挂载
- `content-visibility: auto` 可轻量优化，不替代虚拟列表

### RN
- FlatList 调参：**MUST** [rn/list.md](rn/list.md)

### 小程序
- `scroll-view` / 平台 list；注意与页面滚动冲突
- 分页 cursor；`onPullDownRefresh` 勿与自定义刷新重复绑定
- **setData 只更差分**（见 `../miniprogram-architecture.md`）

## 相关

- [search.md](search.md)（筛选竞态）
- [loading-ux.md](loading-ux.md)
- `../patterns.md` Virtual List
