FROM alpine:3.6
MAINTAINER Eric McNiece <emcniece@gmail.com>

RUN apk --no-cache --update add mysql-client

ADD scripts/run.sh VERSION /
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
    INIT_RESTORE_LATEST="" \
    BACKUP_DIR="/backup" \
    TARGET_DIR="/target"

RUN mkdir /backup /target \
 && chmod +x /run.sh \
 && chmod a+x /usr/bin/backup /usr/bin/restore

VOLUME ["/backup", "/target"]

ENTRYPOINT ["/run.sh"]
