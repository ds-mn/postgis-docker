#!/bin/bash -e
if [ "${SKIP_TIGER_IMPORT:-0}" != 0 ]; then
  exit 0
fi
export PGUSER="$POSTGRES_USER"
export PGDATABASE="$POSTGRES_DB"
export PGPASSWORD="$POSTGRES_PASSWORD"

out_script="/tmp/load_nation.sh"
get_zip=${TIGER_GET_ZIP:-0}
if [ "$get_zip" != 0 ]; then
  psql -c "UPDATE tiger.loader_lookuptables SET load = true WHERE table_name = 'zcta510';"
fi
update_year_query=$(
  cat <<EOF
UPDATE tiger.loader_variables
   SET
       (tiger_year, website_root) = ('${TIGER_YEAR}', REGEXP_REPLACE(website_root, '20\d\d', '${TIGER_YEAR}'));
EOF
)
psql -c "$update_year_query"
psql -tA -c "select loader_generate_nation_script('sh');" >"$out_script"

sed -i -E 's/^.*export\s+PG.*$//i' "$out_script"
sed -i -E 's|^.*PSQL=.*$|PSQL=psql|' "$out_script"

chmod +x "$out_script"
"$out_script"
