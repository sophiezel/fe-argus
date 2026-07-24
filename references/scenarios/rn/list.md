# L2 RN — List

增量（相对 [../list-scroll.md](../list-scroll.md)）：

## FlatList 要点

- `keyExtractor` 稳定；`renderItem` 用 `React.memo` 行组件（测后）
- `getItemLayout` 固定高时开启，减测量
- `windowSize` / `maxToRenderPerBatch` / `removeClippedSubviews` 按真机调
- 下拉：`RefreshControl`；分页：`onEndReached` + 锁，防连触

## 反模式

```tsx
// ❌ 匿名 renderItem={() => <Row data={...} />} 导致整表重渲
// ❌ 大图无缓存、无尺寸 → 滚动掉帧（pit-058 相关）
```
