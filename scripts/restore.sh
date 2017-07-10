#!/bin/sh

MYSQL_HOST=${MYSQL_HOST:-"mysql"}
MYSQL_PORT=${MYSQL_PORT:-"3306"}
MYSQL_USER=${MYSQL_USER:-"mysql"}
MYSQL_PASS=${MYSQL_PASS:-"mysql"}
MYSQL_DB=${MYSQL_DB:-"mysql"}

fullfilename=$1
filename=$(basename "$fullfilename")
ext="${filename##*.}"

if [ "${ext}" = "sql" ]; then
  CAT_CMD=cat
fi

if [ "${ext}" = "gz" ]; then
  CAT_CMD=zcat
fi

echo "Cat_CMD: $CAT_CMD"

if [ -z "$2" ]; then
  echo "=> Restore database from $1"
    if (${CAT_CMD} "$1" | mysql -h${MYSQL_HOST} -P${MYSQL_PORT} -u${MYSQL_USER} -p${MYSQL_PASS} ${MYSQL_DB} ) ;then
      echo "   Restore succeeded"
    else
      echo "   Restore failed"
    fi
else
  echo "=> Restore database $1 from $2 "
    if (${CAT_CMD} "$2" | mysql -h${MYSQL_HOST} -P${MYSQL_PORT} -u${MYSQL_USER} -p${MYSQL_PASS} "$1" ) ;then
      echo "   Restore succeeded"
    else
      echo "   Restore failed"
    fi
fi
echo "=> Done"