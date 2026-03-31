#!/bin/bash
set -eu

exec "__JULIA_BIN__" --startup-file=no --project="__INSTALL_DIR__" -e 'import Pluto; Pluto.run(host="127.0.0.1", port=__PORT__, launch_browser=false, require_secret_for_access=false, require_secret_for_open_links=true)'
