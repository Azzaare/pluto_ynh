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

_ensure_julia_available() {
  if ! command -v "$julia_bin" >/dev/null 2>&1; then
    ynh_die --message="Julia runtime not found. Please install julia_ynh first."
  fi
}

_app_path() {
  local path
  path="$(ynh_app_setting_get --app="$app" --key=path 2>/dev/null || echo "/pluto")"
  ynh_normalize_url_path "${path:-/pluto}"
}

_public_url() {
  local domain path
  domain="$(ynh_app_setting_get --app="$app" --key=domain)"
  path="$(_app_path)"
  if [ "$path" = "/" ]; then
    echo "https://${domain}/"
  else
    echo "https://${domain}${path}"
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
    "$julia_bin" --project="$install_dir" -e 'using Pkg; Pkg.instantiate(); Pkg.update(); Pkg.precompile()'
}
