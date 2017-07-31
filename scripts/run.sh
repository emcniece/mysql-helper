#!/bin/sh

MYSQL_HOST=${MYSQL_HOST:-"mysql"}
MYSQL_PORT=${MYSQL_PORT:-"3306"}
MYSQL_USER=${MYSQL_USER:-"mysql"}
MYSQL_PASS=${MYSQL_PASS:-"mysql"}
MYSQL_DB=${MYSQL_DB:-"mysql"}
BACKUP_DIR=${BACKUP_DIR:-"/backup"}
TARGET_DIR=${TARGET_DIR:-"/target"}

COUNTER=0
MAX_CONN_CHECKS=${MAX_CONN_CHECKS:-20}

test_directories(){
    echo "=> Init Backup Directory: $BACKUP_DIR"
    echo "=> Init Target Directory: $TARGET_DIR"

  if [ ! -d "$BACKUP_DIR" ]; then
    echo "=> Backup directory doesn't exist - creating $BACKUP_DIR"
    mkdir -p $BACKUP_DIR
  fi

  if [ ! -d "$TARGET_DIR" ]; then
    echo "=> Target directory doesn't exist - creating $TARGET_DIR"
    mkdir -p $TARGET_DIR
  fi
}

wait_for_db(){
    until nc -z $MYSQL_HOST $MYSQL_PORT; do
        echo "waiting for database container..."
        sleep 5

        COUNTER=$((COUNTER+1))
        if [ "$COUNTER" -ge "$MAX_CONN_CHECKS" ]; then
            echo "ERROR: could not connect to database"
            exit 1
        fi
    done

    echo "Connected to host/database: $MYSQL_HOST/$MYSQL_DB"
}

restore_latest(){
    if [ -n "${INIT_RESTORE_LATEST}" ]; then
        echo "=> Restoring latest DB backup..."
        ls -d -1 $BACKUP_DIR/* | grep -e .sql$ -e .sql.gz$ | tail -1 | xargs /usr/bin/restore

        echo "=> Restoring latest FILE backup..."
        ls -d -1 $BACKUP_DIR/* | grep -e .tar.gz$ | tail -1 | xargs /usr/bin/restore
    fi

    if [ -n "${INIT_BACKUP}" ]; then
        echo "=> Creating initial backup..."
        /usr/bin/backup
    fi
}

# Do some jobs
test_directories
wait_for_db
restore_latest

# Run cron in foreground
echo "=> Starting cron jobs!"
/usr/sbin/crond -f -l 8
