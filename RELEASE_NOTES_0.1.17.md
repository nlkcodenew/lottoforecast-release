# LottoForecast Pro v0.1.17 (stable)

Bản stable chốt từ beta 0.1.17-beta đã test trên máy thật (rollback 0.1.16 sạch, OTA thử lại).

## Cài / cập nhật

- Máy đang bật OTA: mở app, bản mới tự tải nền và hỏi cài (giữ `lotto.db`/mã máy/log).
- Cài mới: tải `lottoforecast-v0.1.17.zip` bên dưới, đối chiếu `.zip.sha256`, giải nén ra gốc thẻ.

## Có gì so với v0.1.16

- Màn Dự đoán có disclaimer kỳ vọng âm; dãy số/jackpot/hint tự gọn chống tràn màn 4:3.
- Nhẹ thẻ nhớ: đọc trạng thái OTA throttle 2s, log xoay 512KB.
- Tay cầm: map đúng nút, D-pad chéo ăn; footer dài tự xuống 2 dòng.
- Kiểm tra cập nhật thử URL chính rồi fallback jsdelivr; so version chuẩn stable > beta.
- Server: tra cứu máy có index, ép hạn refresh + gói cước phía server, audit mọi hành động
  admin, sale 0đ bắt buộc ghi chú, chi tiết máy giới hạn 100 dự đoán.
- Web quản trị: tab Dự đoán lọc + xem chi tiết kèm KQ thực, số trúng tô màu.
- `launch.sh`: chống chạy sai thư mục/cúm instance/orphan OTA.
- Seed KQ mới (535:#940, 645:#1574, 655:#1409). Manifest ký Ed25519 `kid=r3`, 8 file.
