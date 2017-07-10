FROM alpine:3.6
MAINTAINER Eric McNiece <emcniece@gmail.com>

RUN apk add mysql-client --update

ADD scripts/run.sh /
ADD scripts/backup scripts/restore /usr/bin/

ENV CRON_TIME="0 0 * * *" \
    MYSQL_HOST="mysql" \
    MYSQL_PORT="3306" \
    MYSQL_USER="mysql" \
    MYSQL_PASS="mysql" \
    MYSQL_DB="--all-databases" \
    OPTS="--opt --single-transaction" \
    TAR_GZ="true" \
    MAX_BACKUPS="3" \
    INIT_BACKUP="" \
    INIT_RESTORE_LATEST=""

RUN mkdir /backup \
 && chmod +x /run.sh \
 && chmod a+x /usr/bin/backup /usr/bin/restore \
 && (crontab -u root -l; echo "${CRON_TIME} /bin/sh /usr/bin/backup" ) | crontab -u root -

VOLUME ["/backup"]

ENTRYPOINT ["/run.sh"]
