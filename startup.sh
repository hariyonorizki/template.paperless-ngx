#!/bin/bash
set -e

echo "Starting Paperless-ngx with B2 S3 sync..."

# Hapus semua ENV RCLONE_* supaya gak override config manual
for var in $(env | grep ^RCLONE_ | cut -d= -f1); do
  unset $var
done

# Generate rclone.conf dari ENV
mkdir -p /root/.config/rclone
cat > /root/.config/rclone/rclone.conf <<EOF
[b2remote]
type = s3
provider = Other
access_key_id = ${B2_ACCESS_KEY_ID}
secret_access_key = ${B2_SECRET_ACCESS_KEY}
endpoint = ${B2_ENDPOINT}
region = us-east-005
EOF

# Buat folder jika belum ada
mkdir -p /usr/src/paperless/media/documents

# Test koneksi & buat bucket kalau belum ada
echo "Testing connection to B2..."
rclone lsd b2remote:${B2_BUCKET} --s3-force-path-style -vv || echo "Bucket not found, akan dibuat"
rclone mkdir b2remote:${B2_BUCKET} --s3-force-path-style || true

# ================================
# Jalankan Paperless server **langsung**
# ================================
echo "Starting Paperless-ngx server..."
/entrypoint.sh runserver 0.0.0.0:${PORT:-8000} &

# ================================
# Initial sync dari B2 (background)
# ================================
echo "Starting initial sync from B2 (background)..."
rclone sync b2remote:${B2_BUCKET} /usr/src/paperless/media/documents \
  --s3-force-path-style \
  --create-empty-src-dirs \
  -vv &

# ================================
# Setup cron untuk sinkronisasi balik tiap 5 menit
# ================================
echo "Setting up cron job..."
echo "*/5 * * * * rclone sync /usr/src/paperless/media/documents b2remote:${B2_BUCKET} --s3-force-path-style --create-empty-src-dirs -vv >> /var/log/cron.log 2>&1" | crontab -

# Start cron & log tail
touch /var/log/cron.log
cron
tail -F /var/log/cron.log &

# Tunggu semua background process supaya container tetap hidup
wait
