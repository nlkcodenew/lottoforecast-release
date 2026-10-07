# LottoForecast Pro v0.1.4

## Sửa lỗi mất mạng
- Menu **Giá trị giải thưởng** không còn hiển thị URL hoặc endpoint nội bộ khi máy không có Internet.
- Thông báo mới ngắn gọn: `Không có kết nối mạng • kiểm tra Wi-Fi`.
- Chuẩn hóa lỗi mạng dùng chung để các màn dự đoán, lịch sử và đối chiếu cũng không thể làm lộ URL/backend response.
- Đồng bộ kết quả không còn đưa nguyên lỗi HTTP kỹ thuật lên giao diện.

## An toàn
- `ApiError` không giữ URL request hoặc response body từ máy chủ.
- Manifest OTA được ký Ed25519 `r3`; ZIP và từng file được kiểm tra SHA-256.
- Gói chỉ chứa 8 file runtime; không chứa private key, token, credential hoặc dữ liệu người dùng.
- Binary ARM64/AArch64 đã được strip và kiểm tra chuỗi lỗi kỹ thuật.

## Cảnh báo
Xổ số là ngẫu nhiên và có kỳ vọng âm. Ứng dụng chỉ phục vụ thống kê/giải trí, không cam kết trúng và không phải tư vấn cờ bạc.
