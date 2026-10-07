#!/bin/sh
# launch.sh — LottoForecast Pro (TrimUI Brick Pro, Stock OS).
SDCARD_PATH="${SDCARD_PATH:-/mnt/SDCARD}"
case "$0" in
    /*) APP="${0%/*}" ;;
    */*) APP="$(cd "${0%/*}" 2>/dev/null && pwd)" ;;
    *) APP="$SDCARD_PATH/Apps/LottoForecast" ;;
esac
LOG="$APP/LottoForecast.log"
export LOTTO_APP_DIR="$APP"
# Cert rieng cho curl/wget tren may (he thong thieu issuer): Rust dung webpki-roots nen khong can.
export SSL_CERT_FILE="$APP/certs/cacert.pem"
if [ ! -f "$SSL_CERT_FILE" ] && [ -f /etc/ssl/certs/ca-certificates.crt ]; then
  SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
fi
export CURL_CA_BUNDLE="$SSL_CERT_FILE"
cd "$APP" || exit 1
# OTA tu dong: kiem ban moi nen sau 30s, loi thi bo qua (chi log).
# Tat han: LOTTO_NO_OTA=1. Chi tiet: ota-update.sh (docs/07).
if [ -z "$LOTTO_NO_OTA" ] && [ -f "$APP/ota-update.sh" ]; then
  ( sh "$APP/ota-update.sh" --auto ) >> "$APP/LottoForecast-ota.log" 2>&1 &
fi
./bin/lottoforecast >> "$LOG" 2>&1 &
echo $! > "$APP/lottoforecast.pid"
wait $!
