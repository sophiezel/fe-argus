# L2 RN — List

> Q 命中列表 + React Native 时加载。相对 [list-scroll.md](../list-scroll.md)。

## 适用信号

FlatList 掉帧、整表闪烁、onEndReached 连触、匿名 renderItem 重渲。

---

## FlatList 要点

| 项 | 建议 |
|----|------|
| `keyExtractor` | 稳定业务 id |
| `renderItem` | 抽成 `memo` 行组件；**禁止**内联箭头每次新建 |
| `getItemLayout` | 固定行高时提供，减测量 |
| `windowSize` / `maxToRenderPerBatch` / `initialNumToRender` | 按真机调，默认常偏大 |
| `removeClippedSubviews` | Android 可开；注意焦点/输入行 |
| 下拉 | `RefreshControl`；刷新中锁 |
| 分页 | `onEndReached` + `loadingMore` 锁，防连触 |

## 图片与桥

- 大图定宽高 + 缓存；列表滚动时避免同步桥风暴（pit-058）
- 行内勿每帧 `setState` 全局 store

## 反模式

```tsx
// ❌ renderItem={() => <Row data={item} />} 导致全表重渲
// ❌ 筛选变化后仍 concat 旧页（见 L1 竞态）
// ❌ 首屏与 loadMore 共用一个 loading 卸掉整表
```

## 相关

- [../list-scroll.md](../list-scroll.md)
- pit-058
