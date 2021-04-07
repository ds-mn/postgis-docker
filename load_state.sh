#!/bin/bash -e

readarray -d , -t states <<<"$1"
cleanup() {
  psql -c "SELECT install_missing_indexes()"
  psql -c "VACUUM VERBOSE ANALYZE"
}

out_script="/tmp/load_states.sh"

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
