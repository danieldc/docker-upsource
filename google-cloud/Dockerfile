FROM        frapontillo/upsource:latest
MAINTAINER  Francesco Pontillo <francescopontillo@gmail.com>

ENV         UPSOURCE_BASE_URL http://your-service-ip/
ENV         UPSOURCE_LOGS_DIR /var/upsource/logs
ENV         UPSOURCE_TEMP_DIR /var/upsource/temp
ENV         UPSOURCE_DATA_DIR /var/upsource/data
ENV         UPSOURCE_BACKUPS_DIR /var/upsource/backups
ENV         UPSOURCE_LICENSE_USER_NAME Your Upsource name
ENV         UPSOURCE_LICENSE_KEY yourupsourcelicensekey

RUN         /opt/Upsource/configure.sh