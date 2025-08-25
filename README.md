# Paperless-ngx on Koyeb (Free Tier) with Backblaze B2 Sync

## Setup Overview

Repository ini siap deploy ke Koyeb, sudah optimized agar:
- **Sleep-friendly** (file tetap aman meski container idle/sleep).
- Database di **Supabase** (PostgreSQL), Redis di **Upstash** (Redis serverless).
- File disimpan di **Backblaze B2** via `rclone sync`.

## Cara Deploy

1. **Buka Koyeb Dashboard** → buat App baru.

2. Di tab **Env Vars**, isi dengan (contoh key names):

B2_ACCESS_KEY_ID=<your-backblaze-key-id> B2_SECRET_ACCESS_KEY=<your-backblaze-application-key> B2_ENDPOINT=https://s3.us-west-002.backblazeb2.com B2_BUCKET=paperless-docs

SUPABASE_DB_HOST=<host from supabase> SUPABASE_DB_PORT=5432 SUPABASE_DB_USER=<your db user> SUPABASE_DB_PASS=<your db password> SUPABASE_DB_NAME=<your db name>

UPSTASH_REDIS_URL=<your upstash redis url, e.g. rediss://:pass@host:6379>

PAPERLESS_SECRET_KEY=<random-long-secret> PAPERLESS_URL=https://your-app.koyeb.app

3. Deploy repo via **GitHub Integration** di Koyeb — pastikan Dockerfile di root.

4. Setelah deploy, Paperless-ngx akan:
- Restore dokumen dari B2 saat boot.
- Sinkronisasi tiap 5 menit.
- Terhubung ke Supabase & Upstash via ENV vars.

---

## Kenapa setup ini aman?

- **No secrets in code** — semua keys disimpan di Koyeb env vars.
- **Sinkronisasi dua arah** memastikan data aman jika Koyeb container sleep/hangatau restart.
- **Pure stateless web service** — Koyeb bisa sleep tanpa kehilangan dokumen; semua state (db, redis, storage) persistent di luar.
