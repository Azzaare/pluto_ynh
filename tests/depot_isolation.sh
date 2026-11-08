#!/bin/bash
set -eu
root="$(cd "$(dirname "$0")/.." && pwd)"
fixture="$(mktemp -d)"
trap 'rm -r -- "$fixture"' EXIT
export YNH_APP_BASEDIR="$root"
ynh_die() { return 1; }
ynh_exec_as_app() { "$@"; }
chown() { :; }
source <(sed '\|^source /usr/share/yunohost/helpers$|d' "$root/scripts/_common.sh")
app="$(id -un)"
app_home="$fixture/app"
install_dir="$app_home/pluto"
depot_dir="$app_home/julia_depot"
julia_public_depot="$fixture/shared/.julia"
juliaup_depot="$julia_public_depot"
julia_bin="$fixture/julia"
mkdir -p "$install_dir" "$juliaup_depot/juliaup" "$juliaup_depot/registries/Oasis"
printf 'private fixture\n' > "$juliaup_depot/registries/Oasis/Registry.toml"
chmod 600 "$juliaup_depot/registries/Oasis/Registry.toml"
cat > "$julia_bin" <<'EOF'
#!/bin/bash
set -eu
test "$HOME" = "$FIXTURE_APP_HOME"
test "$JULIA_DEPOT_PATH" = "$FIXTURE_DEPOT"
exit "${FIXTURE_EXIT:-0}"
EOF
chmod 755 "$julia_bin"
export FIXTURE_APP_HOME="$app_home" FIXTURE_DEPOT="$depot_dir"
before="$(stat -c '%a:%u:%g' "$juliaup_depot/registries/Oasis/Registry.toml")"
for status in 0 17; do
  result=0
  FIXTURE_EXIT="$status" _pluto_pkg_exec fixture || result=$?
  test "$result" = "$status"
  test "$(stat -c '%a:%u:%g' "$juliaup_depot/registries/Oasis/Registry.toml")" = "$before"
done
test "$(_pkg_depot_path)" = "$depot_dir"
printf 'PASS: Pluto uses its own writable depot and leaves shared registry permissions intact\n'
