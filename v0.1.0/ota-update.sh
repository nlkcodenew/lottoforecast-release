#!/bin/sh
# ota-update.sh — OTA tu dong cho LottoForecast Pro (TrimUI Brick Pro, Stock OS).
# Dung: sh ota-update.sh --auto | sh ota-update.sh --apply | sh ota-update.sh --check | sh ota-update.sh
# --auto: launch.sh goi nen sau 30s moi lan mo app, khong hoi, loi -> bo qua (chi log).
# --apply: cai ngay khong hoi. --check: chi bao co ban moi khong. Khong doi so: hoi y/N.
# Tat han: LOTTO_NO_OTA=1.
#
# Nguyen tac (docs/07):
# - Tin manifest qua TLS (GitHub/jsdelivr) + verify sha256 TUNG FILE truoc khi chep.
#   (May khong co python3/openssl nen khong verify Ed25519 o shell; tab Cai dat
#   trong app tu verify chu ky Ed25519 truoc khi bao "co ban moi".)
# - KHONG bao gio dung toi du lieu nguoi dung: lotto.db, token.cache/bak,
#   device-id.txt, *.log, *.pid, .ota-status (danh tinh + kich hoat + nhat ky).
# - Chep atomic tung file (.ota-new -> rename); chmod +x cho *.sh + bin/*.
# - OTA KHONG reset/gia han trial.
case "$0" in
  */*)
    cd "$(dirname "$0")" || exit 1
    ;;
esac
APP="$(pwd)"
VERSION_FILE="$APP/VERSION"
CUR="$(cat "$VERSION_FILE" 2>/dev/null | tr -d ' \r\n')"
[ -n "$CUR" ] || CUR="0.0.0"
REPO="${LOTTO_REPO:-nlkcodenew/lottoforecast-release}"
# Goc tai (de test e2e bang server local: LOTTO_RAW_BASE=http://127.0.0.1:8000).
RAW_BASE="${LOTTO_RAW_BASE:-https://raw.githubusercontent.com}"
JSDELIVR="https://cdn.jsdelivr.net/gh/$REPO@main/manifest.json"
if [ -n "${LOTTO_RAW_BASE:-}" ]; then JSDELIVR=""; fi
CA="$APP/certs/cacert.pem"
[ -f "$CA" ] || CA="/etc/ssl/certs/ca-certificates.crt"
LOG="$APP/LottoForecast-ota.log"
TMPD="/tmp/lotto-ota-stage"
MANIFEST_JSON="/tmp/lotto-ota-manifest.json"
say() { echo "[ota] $*"; echo "$(date '+%Y-%m-%d %H:%M:%S' 2>/dev/null) $*" >> "$LOG" 2>/dev/null; }
# File trang thai de app hien thong bao (checking|downloading <ver>|done <ver>|failed).
# Ghi atomic (ghi .tmp roi doi ten), tranh doc ban rong.
OTA_STATUS="$APP/.ota-status"
ota_status() {
  printf "%s" "$*" > "$OTA_STATUS.tmp" 2>/dev/null || true
  mv "$OTA_STATUS.tmp" "$OTA_STATUS" 2>/dev/null || rm -f "$OTA_STATUS.tmp" 2>/dev/null || true
}
ota_clear() { rm -f "$OTA_STATUS" "$OTA_STATUS.tmp" 2>/dev/null || true; }
clean_tmp() { rm -rf "$TMPD" "$MANIFEST_JSON" 2>/dev/null || true; }
# Runtime/dulieu nguoi dung: khong tai, khong chep de.
is_protected() {
  case "$1" in
    lotto.db|token.cache|token.bak|device-id.txt|*.log|*.pid|.ota-status*|*.ota-new) return 0;;
  esac
  return 1
}
# So sanh version dang x.y... (bo hau to chu nhu -phase1 khi so).
# Tra 0 = a moi hon b.
ver_newer() {
  a="$1"; b="$2"
  [ "$a" = "$b" ] && return 1
  i=1
  while :; do
    pa="$(echo "$a" | cut -d. -f$i 2>/dev/null)"; pb="$(echo "$b" | cut -d. -f$i 2>/dev/null)"
    [ -z "$pa$pb" ] && return 1
    pa="${pa%%[!0-9]*}"; pb="${pb%%[!0-9]*}"
    [ -z "$pa" ] && pa=0; [ -z "$pb" ] && pb=0
    pa="$(echo "$pa" | sed 's/^0*//')"; pb="$(echo "$pb" | sed 's/^0*//')"
    [ -z "$pa" ] && pa=0; [ -z "$pb" ] && pb=0
    if [ "$pa" -gt "$pb" ] 2>/dev/null; then return 0; fi
    if [ "$pa" -lt "$pb" ] 2>/dev/null; then return 1; fi
    i=$((i + 1))
    [ "$i" -gt 8 ] && return 1
  done
}
fetch() {
  url="$1"; out="$2"
  if command -v curl >/dev/null 2>&1; then
    if [ -f "$CA" ]; then curl -fsSL --connect-timeout 8 --max-time 25 --retry 0 --cacert "$CA" -o "$out" "$url" 2>/dev/null && return 0; fi
    curl -fsSL --connect-timeout 8 --max-time 25 --retry 0 -o "$out" "$url" 2>/dev/null && return 0
  fi
  if command -v wget >/dev/null 2>&1; then
    if [ -f "$CA" ]; then wget -q --timeout=25 --tries=1 --ca-certificate="$CA" -O "$out" "$url" 2>/dev/null && return 0; fi
    wget -q --timeout=25 --tries=1 -O "$out" "$url" 2>/dev/null && return 0
  fi
  return 1
}
# Tai + verify sha256 bang shell thuan (may khong co python3).
# Doc manifest.json bang awk (manifest do make_release.py sinh, format on dinh).
shell_download_files() {
  LIST="$TMPD.files.list"
  # Tach moi object rieng 1 dong truoc khi parse (manifest pretty-print
  # hay 1 dong deu doc duoc; tranh greedy-match nuot mat file).
  sed 's/},/}\n/g' "$MANIFEST_JSON" 2>/dev/null | awk '
    /"path"/ { p=$0; sub(/.*"path"[[:space:]]*:[[:space:]]*"/, "", p); sub(/".*/, "", p) }
    /"sha256"/ { s=$0; sub(/.*"sha256"[[:space:]]*:[[:space:]]*"/, "", s); sub(/".*/, "", s); if (p != "" && s != "") print p "|" s; p=""; s="" }
  ' > "$LIST" 2>/dev/null
  [ -s "$LIST" ] || { say "Khong doc duoc danh sach file"; return 1; }
  command -v sha256sum >/dev/null 2>&1 || { say "Thieu sha256sum de kiem tra"; return 1; }
  while IFS= read -r e; do
    rel="${e%%|*}"; want="${e##*|}"
    [ -n "$rel" ] && [ -n "$want" ] || return 1
    case "$rel" in /*|*\\*|../*|*/../*|*/..|..) say "Duong dan khong an toan: $rel"; return 1;; esac
    if is_protected "$rel"; then continue; fi
    case "$rel" in data/*|logs/*|dist/*|tests/*|tools/*) continue;; esac
    got=""
    for b in $BASES; do
      if fetch "$b/$rel" "$TMPD.dl.tmp"; then got="$TMPD.dl.tmp"; break; fi
    done
    [ -n "$got" ] || { say "Khong tai duoc: $rel"; return 1; }
    have="$(sha256sum "$got" 2>/dev/null | cut -d' ' -f1)"
    if [ "$have" != "$want" ]; then say "Sai ma kiem tra: $rel"; rm -f "$got"; return 1; fi
    dst="$TMPD/$rel"
    mkdir -p "$(dirname "$dst")" 2>/dev/null
    mv "$got" "$dst" || return 1
    say "ok $rel"
  done < "$LIST"
  n="$(wc -l < "$LIST" 2>/dev/null | tr -d ' ')"
  say "Da tai xong $n file"
  return 0
}
MODE="${1:-}"
if [ "$MODE" = "--auto" ]; then
  # Nen 30s de app mo xong + wifi on dinh (docs/07), roi cai nhu --apply.
  sleep 30
  MODE="--apply"
  AUTO=1
fi
if [ -n "${LOTTO_NO_OTA:-}" ] && [ "$LOTTO_NO_OTA" != "0" ]; then
  [ -n "${AUTO:-}" ] || say "Da tat OTA (LOTTO_NO_OTA=1)."
  exit 0
fi
clean_tmp
mkdir -p "$TMPD" 2>/dev/null || { say "Khong tao duoc thu muc tam"; exit 1; }
MURL="$RAW_BASE/$REPO/main/manifest.json"
say "local=$CUR repo=$REPO"
ota_status "checking"
got_manifest=0
for try in 1 2; do
  if fetch "$MURL" "$MANIFEST_JSON"; then
    got_manifest=1; break
  fi
  if [ -n "$JSDELIVR" ] && fetch "$JSDELIVR" "$MANIFEST_JSON"; then
    got_manifest=1; break
  fi
  [ "$try" = "1" ] && sleep 3
done
[ "$got_manifest" = "1" ] || { say "Khong tai duoc danh muc ban moi"; ota_status "failed"; clean_tmp; exit 1; }
# Bat buoc binary Rust xac minh Ed25519 truoc khi shell tin bat ky hash/path nao
# trong manifest. SHA-256 chi co y nghia sau khi manifest da duoc xac thuc.
if [ ! -x "$APP/bin/lottoforecast" ] || ! "$APP/bin/lottoforecast" --verify-manifest "$MANIFEST_JSON" >> "$LOG" 2>&1; then
  say "Chu ky danh muc khong hop le"
  ota_status "failed"
  clean_tmp
  exit 1
fi
REM="$(grep -o '"version"[[:space:]]*:[[:space:]]*"[^"]*"' "$MANIFEST_JSON" 2>/dev/null | head -n 1 | sed 's/.*"\([^"]*\)"$/\1/')"
[ -n "$REM" ] || { say "Danh muc thieu so phien ban"; ota_status "failed"; clean_tmp; exit 1; }
say "remote=$REM"
if ! ver_newer "$REM" "$CUR"; then
  say "Da la ban moi nhat ($CUR)"
  printf "%s" "$CUR" > "$APP/VERSION" 2>/dev/null || true
  clean_tmp
  ota_clear
  exit 2
fi
if [ "$MODE" = "--check" ]; then
  say "Co ban moi: $REM (dang dung $CUR). Chay sh ota-update.sh --apply de cap nhat."
  clean_tmp
  ota_clear
  exit 10
fi
BASES="$RAW_BASE/$REPO/v$REM $RAW_BASE/$REPO/main"
if [ -z "${LOTTO_RAW_BASE:-}" ]; then
  BASES="$BASES https://cdn.jsdelivr.net/gh/$REPO@v$REM"
fi
if [ "$MODE" != "--apply" ]; then
  printf "Co ban moi %s (hien tai %s). Cap nhat? [y/N] " "$REM" "$CUR"
  read -r ans
  case "$ans" in y|Y|yes|YES) ;; *) say "Da huy"; clean_tmp; ota_clear; exit 3;; esac
fi
say "Dang tai $REM ..."
ota_status "downloading $REM"
if shell_download_files; then DL_OK=1; else DL_OK=0; fi
if [ "$DL_OK" != "1" ]; then say "Tai file that bai"; ota_status "failed"; clean_tmp; exit 1; fi
# Apply: khong dung pipe-while (exit trong subshell khong lan ra ngoai).
LIST="$TMPD.apply.list"
(cd "$TMPD" && find . -type f -print > "$LIST") || { say "Cai dat that bai"; ota_status "failed"; clean_tmp; exit 1; }
APPLY_FAIL=0
while IFS= read -r f; do
  [ -n "$f" ] || continue
  rel="${f#./}"
  case "$rel" in *.apply.list|*.files.list) continue;; esac
  if is_protected "$rel"; then continue; fi
  case "$rel" in data/*|logs/*) continue;; esac
  [ -f "$TMPD/$rel" ] || continue
  dst="$APP/$rel"
  mkdir -p "$(dirname "$dst")" 2>/dev/null
  tmp="$dst.ota-new"
  if ! cp "$TMPD/$rel" "$tmp" 2>/dev/null; then say "Chep that bai: $rel"; APPLY_FAIL=1; break; fi
  case "$rel" in *.sh|bin/*) chmod +x "$tmp" 2>/dev/null;; esac
  if ! mv "$tmp" "$dst" 2>/dev/null; then say "Cai dat that bai: $rel"; APPLY_FAIL=1; break; fi
  say "installed $rel"
done < "$LIST"
if [ "$APPLY_FAIL" != "0" ]; then ota_status "failed"; clean_tmp; exit 1; fi
cd "$APP" || exit 1
printf "%s" "$REM" | tr -d " \r\n" > "$APP/VERSION" 2>/dev/null
say "Cap nhat xong $CUR -> $REM. Thoat app va mo lai."
ota_status "done $REM"
clean_tmp
exit 0
