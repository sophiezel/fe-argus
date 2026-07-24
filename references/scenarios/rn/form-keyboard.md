# L2 RN — Form & Keyboard

增量：React Native 表单与键盘。

## 键盘遮挡

1. 优先 `KeyboardAvoidingView`（`behavior`: iOS `padding`，Android 常 `height` 或依赖 `windowSoftInputMode`）
2. 或 `KeyboardAwareScrollView`（社区）包住表单
3. Android：`android:windowSoftInputMode="adjustResize"`（原生工程配置）与 RN 行为一致
4. 聚焦 `TextInput` 时 `scrollToFocusedInput`；多输入长表单必须可滚

```tsx
// ✅ 典型
<KeyboardAvoidingView behavior={Platform.OS === 'ios' ? 'padding' : undefined} style={{ flex: 1 }}>
  <ScrollView keyboardShouldPersistTaps="handled">{/* fields */}</ScrollView>
</KeyboardAvoidingView>
```

## 其它坏 case

- `keyboardShouldPersistTaps="handled"`：点按钮时不先收键盘导致 onPress 丢失
- 安全区：`SafeAreaView` / `useSafeAreaInsets`，底栏勿被 Home Indicator 挡
- 中文 IME：RN TextInput 无 DOM composition 事件——用受控值；避免每个 `onChangeText` 立即导航/搜索时打拼音中间态（可对搜索做短 debounce + 不在 composing 语义下可用结束编辑再搜）

## 反模式

```tsx
// ❌ 无 Avoiding，底部提交按钮被键盘永远挡住
// ❌ 外层 ScrollView 与内层冲突抢手势
```

## 相关

- [../form-input.md](../form-input.md) · [../search.md](../search.md)
- pit-014 / pit-058（RN 性能与桥，列表场景叠加）
