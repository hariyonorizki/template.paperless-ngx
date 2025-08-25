#!/bin/bash
set -e

echo "Starting Paperless-ngx with B2 sync..."

# Buat folder jika belum ada
mkdir -p /usr/src/paperless/media/documents

# Restore dokumen dari B2 saat startup
echo "Syncing from Backblaze B2..."
rclone sync b2remote:${B2_BUCKET} /usr/src/paperless/media/documents --create-empty-src-dirs

# Setup cron untuk sinkronisasi balik setiap 5 menit
echo "Setting up cron job..."
echo "*/5 * * * * rclone sync /usr/src/paperless/media/documents b2remote:${B2_BUCKET} --create-empty-src-dirs >> /var/log/cron.log 2>&1" | crontab -

# Jalankan cron (daemon)
cron

# Jalankan Paperless-ngx
echo "Starting Paperless-ngx server..."
exec /usr/src/paperless/docker-entrypoint.sh runserver 0.0.0.0:8000
