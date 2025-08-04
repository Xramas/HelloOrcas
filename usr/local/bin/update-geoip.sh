#!/bin/bash
set -e

DB_DIR="/usr/share/GeoIP"
mkdir -p "$DB_DIR"

# 数据库 URL
CITY_V4_URL="https://cdn.jsdelivr.net/npm/@ip-location-db/geolite2-city-mmdb/geolite2-city-ipv4.mmdb"
CITY_V6_URL="https://cdn.jsdelivr.net/npm/@ip-location-db/geolite2-city-mmdb/geolite2-city-ipv6.mmdb"
ASN_URL="https://cdn.jsdelivr.net/npm/@ip-location-db/asn-mmdb/asn.mmdb"

# 数据库文件
CITY_V4_FILE="$DB_DIR/geolite2-city-ipv4.mmdb"
CITY_V6_FILE="$DB_DIR/geolite2-city-ipv6.mmdb"
ASN_FILE="$DB_DIR/asn.mmdb"

echo "[*] 下载最新 GeoLite2 City (IPv4)..."
curl -L -o "${CITY_V4_FILE}.tmp" "$CITY_V4_URL"
mv "${CITY_V4_FILE}.tmp" "$CITY_V4_FILE"

echo "[*] 下载最新 GeoLite2 City (IPv6)..."
curl -L -o "${CITY_V6_FILE}.tmp" "$CITY_V6_URL"
mv "${CITY_V6_FILE}.tmp" "$CITY_V6_FILE"

echo "[*] 下载最新 ASN 数据库..."
curl -L -o "${ASN_FILE}.tmp" "$ASN_URL"
mv "${ASN_FILE}.tmp" "$ASN_FILE"

chmod 644 "$DB_DIR"/*.mmdb
echo "[*] 数据库更新完成：$DB_DIR"
