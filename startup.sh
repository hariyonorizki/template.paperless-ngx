#!/bin/bash
set -e

echo "Starting Paperless-ngx with B2 S3 sync..."

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

# Restore dokumen dari B2 saat startup
echo "Syncing from Backblaze B2 (S3 API)..."
rclone sync b2remote:${B2_BUCKET} /usr/src/paperless/media/documents --create-empty-src-dirs || true

# Setup cron untuk sinkronisasi balik setiap 5 menit
echo "Setting up cron job..."
echo "*/5 * * * * rclone sync /usr/src/paperless/media/documents b2remote:${B2_BUCKET} --create-empty-src-dirs >> /var/log/cron.log 2>&1" | crontab -

# Jalankan cron (daemon)
cron

# Jalankan Paperless-ngx
echo "Starting Paperless-ngx server..."
exec /entrypoint.sh runserver 0.0.0.0:8000
