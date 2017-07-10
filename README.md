# emcniece/mysql-helper

DockerHub: [emcniece/mysql-helper](https://hub.docker.com/r/emcniece/mysql-helper/)

Helper container for MySQL instances that provides auto-import on first run and timed backups. Small, flexible, handles `.sql.gz` formats.

Inspired by [yloeffler/mysql-backup](https://hub.docker.com/r/yloeffler/mysql-backup/).

## Quickstart

Docker-Compose, with a demo MySQL container:

```
docker-compose up -d
```

Or regular Docker syntax for your own host:

```
docker pull emcniece/mysql-helper

docker run -d \
  -e MYSQL_HOST=my-sql-service \
  -e MYSQL_PORT=3306 \
  -e MYSQL_USER=mysql \
  -e MYSQL_PASS=mysql \
  -v ./backup:/backup
  emcniece/mysql-helper
```

## Environment Variables

The following variables can be set and overridden:

```
# Cron task intervals
# Default: once per hour
CRON_TIME="0 0 * * *"

# Regular MySQL connection
MYSQL_HOST="mysql"
MYSQL_PORT="3306"
MYSQL_USER="mysql"
MYSQL_PASS="mysql"

# Specify database, or backup all present
MYSQL_DB="--all-databases"

# Additional MySQL command options
OPTS="--opt --single-transaction"

# Archive/compress backups
TAR_GZ="true"

# Limit number of stored backups
MAX_BACKUPS="3"

# Import a database on startup
# Searches for the most recent `.sql` or `.gz` file in the backup dir
# Runs before the INIT_BACKUP process
# Values: "false" (default), "true"
INIT_RESTORE_LATEST="false"

# Create a backup on startup
# Runs after INIT_RESTORE_LATEST
INIT_BACKUP="false"
```

## Building

If you have Make installed, the Makefile will help with building the container.

```sh
# Show commands
make

# Build image
make image

# Run container normally
make run

# Run container without starting app
make run-debug

# Remove image from your system
make clean
```
