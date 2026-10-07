# LottoForecast Pro v0.1.2

## OTA mới
- Thanh tiến độ tải xuống theo tổng số byte thực tế.
- Thanh tiến độ cài đặt theo số file đã hoàn tất.
- Trạng thái rõ ràng: kiểm tra, có bản mới, tải, cài, hoàn tất và thất bại.
- Khi hoàn tất, bấm **A** để khởi động lại ứng dụng ngay.
- Launcher hỗ trợ exit code `42` và tự mở lại app.
- Có khóa chống chạy trùng hai updater.

## An toàn
- Vẫn bắt buộc chữ ký Ed25519 và SHA-256 từng file.
- Cài file theo kiểu atomic.
- Không ghi đè DB, token, device ID hoặc log người dùng.
- Đã kiểm thử nâng cấp từ updater `0.1.1` lên `0.1.2`, theo dõi progress và restart hai vòng.

## Lưu ý trải nghiệm
Khi nâng từ `0.1.1` lên `0.1.2`, app cũ chưa có UI progress mới. Sau khi lên `0.1.2`, các lần cập nhật tiếp theo sẽ hiển thị đầy đủ thanh tiến độ và nút A khởi động lại.

## Cảnh báo
Xổ số là ngẫu nhiên và có kỳ vọng âm. Ứng dụng chỉ phục vụ thống kê/giải trí, không cam kết trúng và không phải tư vấn cờ bạc.
