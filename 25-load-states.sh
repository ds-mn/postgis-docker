#!/bin/bash -e

if [ "${SKIP_TIGER_IMPORT:-0}" != 0 ]; then
  exit 0
fi
export PGUSER="$POSTGRES_USER"
export PGDATABASE="$POSTGRES_DB"
export PGPASSWORD="$POSTGRES_PASSWORD"

cleanup() {
  psql -c "SELECT install_missing_indexes()"
  psql -c "VACUUM VERBOSE ANALYZE"
  #  rm -r /gisdata/*
}

if [[ -z "${TIGER_STATES}" ]]; then
  cleanup
  exit
fi

out_script="/tmp/load_states.sh"

readarray -d , -t states <<<"$TIGER_STATES"
comb_states=""
for ((n = 0; n < ${#states[*]}; n++)); do
  st=$(tr -d ' ' <<<"${states[n]}")
  if [ ${#st} = 2 ]; then
    comb_states="${comb_states},'${st}'"
  fi
done
comb_states=${comb_states:1}

query="SELECT loader_generate_script(ARRAY[${comb_states}], 'sh')"

psql -tA -c "$query" >"$out_script"

sed -i -E 's/^.*export\s+PG.*$//i' "$out_script"
sed -i -E 's|^.*PSQL=.*$|PSQL=psql|' "$out_script"

chmod +x "$out_script"
"$out_script"
cleanup
