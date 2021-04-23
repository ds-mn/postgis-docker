#!/bin/bash
export PGDATABASE=$POSTGRES_DB
export PGPASSWORD=$POSTGRES_PASSWORD


excludes=$(psql -c '\dm *.*' -t | grep -v '^\s*$' |
  awk -F'|' '{print $1"."$2;}' | sed -E 's|\s+||g' |
  xargs -n1 -I{} echo '--exclude-table-data={}')

cmd_args="-T '*.spatial_ref_sys' -N tiger -N tiger_data -N topology $excludes"
cmd_args=$(echo "$cmd_args" | tr '\n' ' ')

fn=$(date +%Y-%m-%d_%H.%M.%S).pgbackup
cmd_args="${cmd_args} -Fc -b -v -Z7 -f /backup/${fn} -C -c --if-exists"
pg_dump $cmd_args
