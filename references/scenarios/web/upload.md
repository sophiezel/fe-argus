# L2 Web — Upload

增量（相对 [../media-upload.md](../media-upload.md)）：

- `<input type="file" accept>` + drag-drop；`DataTransfer` 校验
- 大文件考虑分片（按后端协议）；`fetch` 进度需 ReadableStream/XHR
- 注意内存：ImageBitmap 用完 `close()`
