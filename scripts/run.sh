#!/bin/sh

MYSQL_HOST=${MYSQL_HOST:-"mysql"}
MYSQL_PORT=${MYSQL_PORT:-"3306"}
MYSQL_USER=${MYSQL_USER:-"mysql"}
MYSQL_PASS=${MYSQL_PASS:-"mysql"}
MYSQL_DB=${MYSQL_DB:-"mysql"}

COUNTER=0
MAX_CONN_CHECKS=${MAX_CONN_CHECKS:-40}

until nc -z $MYSQL_HOST $MYSQL_PORT; do
    echo "waiting for database container..."
    sleep 1

    COUNTER=$((COUNTER+1))
    if [ "$COUNTER" -ge "$MAX_CONN_CHECKS" ]; then
        echo "ERROR: could not connect to database"
        exit 1
    fi
done

echo "Connected to host/database: $MYSQL_HOST/$MYSQL_DB"

if [ -n "${INIT_RESTORE_LATEST}" ]; then
    echo "=> Restoring latest DB backup..."
    ls -d -1 /backup/* | grep -e .sql$ -e .sql.gz$ | tail -1 | xargs /usr/bin/restore

    echo "=> Restoring latest FILE backup..."
    ls -d -1 /backup/* | grep -e .tar.gz$ | tail -1 | xargs /usr/bin/restore
fi

if [ -n "${INIT_BACKUP}" ]; then
    echo "=> Creating initial backup..."
    /usr/bin/backup
fi

#Run cron in foreground
/usr/sbin/crond -f -l 8
