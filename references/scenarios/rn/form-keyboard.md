# L2 RN — Form & Keyboard

> Q 命中表单/键盘 + React Native 时加载。相对 [form-input.md](../form-input.md)。

## 适用信号

TextInput 被软键盘挡住；点击提交无响应；长表单无法滚到焦点。

---

## 标准解法

1. `KeyboardAvoidingView`：`behavior` iOS 常用 `padding`；Android 依赖 `windowSoftInputMode`（`adjustResize`）时 often 不设或 `height`
2. 或社区 `KeyboardAwareScrollView` 包住表单
3. 外层 `ScrollView` + `keyboardShouldPersistTaps="handled"`——否则先收键盘吃掉 onPress
4. 多字段：聚焦时滚到输入（库或 `measure` + `scrollTo`）
5. 安全区：`useSafeAreaInsets`，底栏勿被 Home Indicator 挡

```tsx
<KeyboardAvoidingView
  behavior={Platform.OS === 'ios' ? 'padding' : undefined}
  style={{ flex: 1 }}
  keyboardVerticalOffset={headerHeight}
>
  <ScrollView keyboardShouldPersistTaps="handled">{/* fields */}</ScrollView>
</KeyboardAvoidingView>
```

## IME / 搜索

RN TextInput **无** DOM `composition*`。即时搜索：短 debounce；避免每个拼音字母打接口；可「结束编辑 / 点搜索」再请求。

## 反模式

```tsx
// ❌ 无 Avoiding，底按钮永远在键盘下
// ❌ 嵌套 ScrollView 抢手势
// ❌ keyboardShouldPersistTaps 默认，按钮要点两次
```

## 相关

- [../form-input.md](../form-input.md) · [../search.md](../search.md)
- pit-014 / pit-058（列表性能叠加 [list.md](list.md)）
