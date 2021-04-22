#!/bin/bash
backup_file="$BACKUP_FILE_NAME"
db_name=$PGDATABASE
pg_restore -c -d ${db_name} --if-exists -v -j4 -O -l /backup/${backup_file} >/tmp/db.list

grep -v '^;' /tmp/db.list |
  grep -v -E '^[0-9; ]+(SCHEMA|DEFAULT|COMMENT|CONSTRAINT|INDEX|TABLE|EXTENSION)( DATA| - SCHEMA| -| - EXTENSION)? (tiger|tiger_data|topology|postgis[^ ]*|public spatial_ref_sys)' >/tmp/db.list.edited

pg_restore -c -d ${db_name} --if-exists -v -j4 -O -L /tmp/db.list.edited "/backup/${backup_file}" 2> >(tee /tmp/restore.log >&2)
