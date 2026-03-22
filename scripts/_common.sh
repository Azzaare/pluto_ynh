#!/bin/bash
set -eu

# shellcheck disable=SC1091
source /usr/share/yunohost/helpers

app=${YNH_APP_INSTANCE_NAME:-pluto}
app_home="/var/lib/$app"
install_dir="${install_dir:-$app_home/pluto}"
data_dir="${data_dir:-$app_home/notebooks}"
depot_dir="${depot_dir:-$app_home/julia_depot}"
julia_bin="/usr/local/bin/julia"
juliaup_bin="/usr/local/bin/juliaup"

_find_free_port() {
  local port="${1:-1234}"
  while ss -lnt "sport = :$port" | grep -q LISTEN; do
    port=$((port + 1))
  done
  echo "$port"
}

_ensure_julia_available() {
  if ! command -v "$julia_bin" >/dev/null 2>&1; then
    ynh_die --message="Julia runtime not found. Please install julia_ynh first."
  fi
}

_pluto_install_deps() {
  mkdir -p "$depot_dir"
  chown -R "$app:$app" "$depot_dir"

  ynh_exec_as_app env JULIA_DEPOT_PATH="$depot_dir" \
    "$julia_bin" --project="$install_dir" -e 'using Pkg; Pkg.add("Pluto")'
}

_pluto_update_deps() {
  ynh_exec_as_app env JULIA_DEPOT_PATH="$depot_dir" \
    "$julia_bin" --project="$install_dir" -e 'using Pkg; Pkg.update()'
}
