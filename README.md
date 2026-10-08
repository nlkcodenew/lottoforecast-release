# LottoForecast Pro — Releases

Kho phát hành công khai cho **LottoForecast Pro** trên TrimUI Brick Pro (`1024×768`).

## Cài đặt mới

1. Tải `lottoforecast-v0.1.6.zip` trong phần **Releases**.
2. Kiểm tra SHA-256 theo file `lottoforecast-v0.1.6.zip.sha256`.
3. Giải nén vào thư mục gốc của thẻ nhớ để nhận `Apps/LottoForecast/`.
4. Mở LottoForecast từ danh sách Apps.

## Cập nhật OTA

Ứng dụng kiểm tra `manifest.json`, xác minh chữ ký Ed25519 trong binary, tải từng file và kiểm tra SHA-256 trước khi thay thế atomic. OTA không ghi đè `lotto.db`, token, device ID hoặc log của người dùng.

## Lưu ý

- Chỉ hỗ trợ TrimUI Brick Pro/AArch64 Stock OS ở bản này.
- Xổ số là ngẫu nhiên và có kỳ vọng âm. Ứng dụng chỉ phục vụ thống kê/giải trí, không cam kết trúng và không phải tư vấn cờ bạc.
- Mã nguồn được quản lý trong kho private riêng; repo này chỉ chứa file runtime và artifact phát hành.
