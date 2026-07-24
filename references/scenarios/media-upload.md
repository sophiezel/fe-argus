# L1 — Media Upload（上传）

## 适用信号

选图/文件、压缩、进度、失败重试、多文件队列、类型/大小限制。

---

## 标准解法

### 1. 客户端预检

MIME/扩展名、大小上限、张数；失败即时提示，避免无效上行。

### 2. 压缩与方向

大图压缩；注意 EXIF 旋转；Web 用 canvas/createImageBitmap，注意内存。

### 3. 进度与取消

`XMLHttpRequest.upload` / fetch + 可读流（支持度因环境而异）；提供取消；卸载时 abort。

### 4. 队列与并发

限制并发（如 2–3）；失败单项重试，勿整队重传。

### 5. 安全

不要把本地路径当可信 URL；服务端再校验；鉴权 token 勿进可分享链接。

---

## 反模式

```ts
// ❌ 不压缩直接传数十 MB
// ❌ 无进度无取消，用户反复点击堆多请求
// ❌ 仅前端校验类型（改后缀绕过）
```

---

## L2 指针

- [web/upload.md](web/upload.md)
- [rn/upload.md](rn/upload.md)
- [miniprogram/upload.md](miniprogram/upload.md)

## 相关

- [async-resilience.md](async-resilience.md)
- [device-permission.md](device-permission.md)
