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
export LOTTO_LAUNCH_LOOP=1
case "$(cat "$APP/.ota-status" 2>/dev/null)" in
  done*) rm -f "$APP/.ota-status" "$APP/.ota-status.tmp" 2>/dev/null;;
esac
# OTA tu dong: kiem ban moi nen sau 30s, loi thi bo qua (chi log).
# Tat han: LOTTO_NO_OTA=1. Chi tiet: ota-update.sh (docs/07).
if [ -z "$LOTTO_NO_OTA" ] && [ -f "$APP/ota-update.sh" ]; then
  ( sh "$APP/ota-update.sh" --auto ) >> "$APP/LottoForecast-ota.log" 2>&1 &
fi
while :; do
  ./bin/lottoforecast >> "$LOG" 2>&1 &
  APP_PID=$!
  echo "$APP_PID" > "$APP/lottoforecast.pid"
  wait "$APP_PID"
  EXIT_CODE=$?
  [ "$EXIT_CODE" = "42" ] || break
  echo "[ota] restart requested" >> "$LOG"
  rm -f "$APP/.ota-status" "$APP/.ota-status.tmp" 2>/dev/null
  sleep 1
done
sync
exit "$EXIT_CODE"
