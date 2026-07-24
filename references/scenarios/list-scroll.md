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

## L2 指针

- [web/list.md](web/list.md)
- [rn/list.md](rn/list.md) — FlatList 配置坑
- [miniprogram/list.md](miniprogram/list.md)

## 相关

- [search.md](search.md)（筛选竞态）
- [loading-ux.md](loading-ux.md)
- `../patterns.md` Virtual List
