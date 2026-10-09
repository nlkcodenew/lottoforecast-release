# LottoForecast Pro v0.1.16

- AI xếp lại chạy trên máy chủ khi bật trong app; base URL, API key và model do quản trị viên cấu hình trên Worker, không nằm trong bản phát hành.
- Phiên đăng nhập chỉ giữ trong RAM; app xóa các file credential cũ khi khởi động. Không tạo dự đoán offline khi máy chủ không phản hồi.
- Lịch sử lấy lại nhãn AI từ máy chủ; thất bại AI vẫn trả các dãy premium mặc định và không gắn nhãn AI.
- OTA không ghi đè `lotto.db`, device ID hoặc log của người dùng. Cần mạng để mở phiên và tạo dự đoán.

Xổ số là ngẫu nhiên; ứng dụng chỉ phục vụ thống kê/giải trí và không cam kết trúng thưởng.
