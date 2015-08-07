FROM        ubuntu:14.04
MAINTAINER  Francesco Pontillo <francescopontillo@gmail.com>

RUN         apt-get update -y && apt-get install -y \
            software-properties-common \
            unzip \
            wget
RUN         echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN         add-apt-repository ppa:webupd8team/java -y \
            && apt-get update -y && apt-get install -y \
            oracle-java8-installer \
            oracle-java8-set-default
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
RUN         chmod +x /opt/Upsource/bin/upsource.sh

EXPOSE 8080
CMD []
ENTRYPOINT ["/opt/Upsource/bin/upsource.sh", "run"]