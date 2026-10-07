# LottoForecast Pro v0.1.3

## Giá trị giải thưởng
- Thêm menu **Giá trị giải thưởng** ở đầu màn hình chính.
- Hiển thị giá trị hiện tại của Lotto 5/35, Mega 6/45 và Power 6/55 từ backend.
- Mega 6/45 tự hiển thị mức khởi điểm `12.000.000.000 VNĐ` sau kỳ có người trúng Jackpot.
- Power 6/55 chỉ hiển thị Jackpot 1 theo yêu cầu.
- App chỉ đọc API; không tự cào trang Vietlott.

## Kết quả Lotto 5/35
- Backend ưu tiên cào trực tiếp Vietlott trước, mirror chỉ dùng để bù lịch sử.
- Thêm các lượt retry lúc 14:15, 14:30, 22:15 và 22:30 GMT+7 để bắt dữ liệu công bố trễ.
- Đã xác minh kỳ `#00931` ngày 07/10/2026 được backend nhận và trả qua API.

## An toàn
- Manifest OTA vẫn bắt buộc chữ ký Ed25519 `r3`.
- ZIP và từng file đều được kiểm tra SHA-256; quyền thực thi Unix được giữ nguyên.
- Không ghi đè DB, token, device ID hoặc log người dùng.
- Binary ARM64 đã quét chuỗi bí mật; source không chứa private key/token.

## Cảnh báo
Xổ số là ngẫu nhiên và có kỳ vọng âm. Ứng dụng chỉ phục vụ thống kê/giải trí, không cam kết trúng và không phải tư vấn cờ bạc.
