FROM alpine:3.6
MAINTAINER Eric McNiece <emcniece@gmail.com>

RUN apk add mysql-client --update

ADD scripts/run.sh scripts/backup.sh scripts/restore.sh /

RUN mkdir /backup \
 && chmod +x /run.sh /backup.sh /restore.sh

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

VOLUME ["/backup"]

ENTRYPOINT ["/run.sh"]
