#!/bin/bash
set -eu

# shellcheck disable=SC1091
source /usr/share/yunohost/helpers

app=${YNH_APP_INSTANCE_NAME:-pluto}
app_home="/var/lib/$app"
install_dir="${install_dir:-$app_home/pluto}"
data_dir="${data_dir:-$app_home/notebooks}"
depot_dir="${depot_dir:-$app_home/julia_depot}"
julia_public_depot="/var/lib/julia/.julia"
juliaup_depot="/var/lib/julia/.julia"
julia_bin="/usr/local/bin/julia"
juliaup_bin="/usr/local/bin/juliaup"

_ensure_julia_available() {
  if ! command -v "$julia_bin" >/dev/null 2>&1; then
    ynh_die --message="Julia runtime not found. Please install julia_ynh first."
  fi
}

_runtime_depot_path() {
  printf '%s:%s' "$depot_dir" "$julia_public_depot"
}

_pkg_depot_path() {
  printf '%s:%s' "$julia_public_depot" "$depot_dir"
}

_normalize_shared_public_depot_permissions() {
  mkdir -p "$julia_public_depot"
  chown -R julia:julia "$julia_public_depot"
  find "$julia_public_depot" -type d -exec chmod 755 {} \; 2>/dev/null || true
  chmod -R a+rX "$julia_public_depot" 2>/dev/null || true
  chmod -R go-w "$julia_public_depot" 2>/dev/null || true
  if [ -d "$julia_public_depot/logs" ]; then
    chmod 1777 "$julia_public_depot/logs"
  fi
}

_normalize_instance_depot_permissions() {
  mkdir -p "$depot_dir"
  chown -R "$app:$app" "$depot_dir"
  chmod 700 "$depot_dir"
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
  _normalize_instance_depot_permissions
  _normalize_shared_public_depot_permissions

  env \
    HOME="/root" \
    JULIAUP_DEPOT_PATH="$juliaup_depot" \
    JULIA_DEPOT_PATH="$(_pkg_depot_path)" \
    JULIA_PKG_PRECOMPILE_AUTO=0 \
    "$julia_bin" --project="$install_dir" --startup-file=no -e 'using Pkg; Pkg.add("Pluto"); Pkg.instantiate(); Pkg.precompile()'

  _normalize_shared_public_depot_permissions
  _normalize_instance_depot_permissions
}

_pluto_update_deps() {
  _normalize_instance_depot_permissions
  _normalize_shared_public_depot_permissions

  env \
    HOME="/root" \
    JULIAUP_DEPOT_PATH="$juliaup_depot" \
    JULIA_DEPOT_PATH="$(_pkg_depot_path)" \
    JULIA_PKG_PRECOMPILE_AUTO=0 \
    "$julia_bin" --project="$install_dir" --startup-file=no -e 'using Pkg; Pkg.instantiate(); Pkg.update(); Pkg.precompile()'

  _normalize_shared_public_depot_permissions
  _normalize_instance_depot_permissions
}
