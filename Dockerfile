FROM        frapontillo/java:8
MAINTAINER  Francesco Pontillo <francescopontillo@gmail.com>

RUN         apt-get update -y && apt-get install -y \
            unzip \
            wget
RUN         printf '%s\n%s\n%s\n%s\n' \
            '* - memlock unlimited' \
            '* - nofile 100000' \
            '* - nproc 32768' \
            '* - as unlimited' \
            >> /etc/security/limits.conf
RUN         cd /opt/ \
            && wget https://download.jetbrains.com/upsource/upsource-2.0.3554.zip \
            && chmod a+x upsource-2.0.3554.zip \
            && unzip upsource-2.0.3554.zip \
            && chmod -R a+rwX /opt/Upsource \
            && rm upsource-2.0.3554.zip

ENV         UPSOURCE_LOGS_DIR /opt/Upsource/logs
ENV         UPSOURCE_TEMP_DIR /opt/Upsource/temp
ENV         UPSOURCE_DATA_DIR /opt/Upsource/data
ENV         UPSOURCE_BACKUPS_DIR /opt/Upsource/backups

RUN         /opt/Upsource/bin/upsource.sh configure \
            --logs-dir=$UPSOURCE_LOGS_DIR \
            --temp-dir=$UPSOURCE_TEMP_DIR \
            --data-dir=$UPSOURCE_DATA_DIR \
            --backups-dir=$UPSOURCE_BACKUPS_DIR

EXPOSE 8080
CMD []
ENTRYPOINT ["/opt/Upsource/bin/upsource.sh", "run"]