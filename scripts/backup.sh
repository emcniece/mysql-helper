#!/bin/sh

MYSQL_HOST=${MYSQL_HOST:-"mysql"}
MYSQL_PORT=${MYSQL_PORT:-"3306"}
MYSQL_USER=${MYSQL_USER:-"mysql"}
MYSQL_PASS=${MYSQL_PASS:-"mysql"}
MYSQL_DB=${MYSQL_DB:-"mysql"}

print_log(){
  echo $1
}

backup_db(){
  if [ "$TAR_GZ" = "true" ]; then
    BACKUP_NAME="$BACKUP_NAME.gz"
  fi

  print_log "=> Backup started: ${BACKUP_NAME}"
  #print_log "    $BACKUP_CMD"

  if [ "$TAR_GZ" = "true" ]; then
    if ${BACKUP_CMD} | gzip > /backup/${BACKUP_NAME}; then
      print_log "   Backup succeeded"
    else
      print_log "   Backup failed"
      rm -rf /backup/${BACKUP_NAME}
    fi
  else
    if ${BACKUP_CMD} > /backup/${BACKUP_NAME}; then
      print_log "   Backup succeeded"
    else
      print_log "   Backup failed"
      rm -rf /backup/${BACKUP_NAME}
    fi
  fi
}

if ! $(mysql -h ${MYSQL_HOST} -u ${MYSQL_USER} -p${MYSQL_PASS} -e "quit" || exit 1); then
  print_log "Error connecting to database"
  exit 1
fi

if [ "${MYSQL_DB}" != "--all-databases" ]; then
  for db in ${MYSQL_DB}; do

    BACKUP_NAME=${db}-$(date +\%Y\%m\%d-\%H\%M\%S).sql
    BACKUP_CMD="mysqldump ${OPTS} -h ${MYSQL_HOST} -P ${MYSQL_PORT} -u ${MYSQL_USER} -p${MYSQL_PASS} ${EXTRA_OPTS} ${db}"

    backup_db $BACKUP_NAME $BACKUP_CMD
  done
else
  MYSQL_DB="--all-databases"
  BACKUP_NAME=$(date +\%Y\%m\%d-\%H\%M\%S).sql
  BACKUP_CMD="mysqldump ${OPTS} -h ${MYSQL_HOST} -P ${MYSQL_PORT} -u ${MYSQL_USER} -p${MYSQL_PASS} ${EXTRA_OPTS} ${MYSQL_DB}"

  backup_db
fi

if [ -n "${MAX_BACKUPS}" ]; then
    while [ $(ls /backup -1 | wc -l) -gt ${MAX_BACKUPS} ]; do
      BACKUP_TO_BE_DELETED=$(ls /backup -1 | sort | head -n 1)
      print_log "   Backup ${BACKUP_TO_BE_DELETED} is deleted"
      rm -rf /backup/${BACKUP_TO_BE_DELETED}
    done
fi

print_log "=> Backup done"
