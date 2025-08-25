FROM ghcr.io/paperless-ngx/paperless-ngx:latest

# Install rclone & cron
RUN apt-get update && apt-get install -y rclone cron && rm -rf /var/lib/apt/lists/*

COPY startup.sh /startup.sh
RUN chmod +x /startup.sh

CMD ["/startup.sh"]
