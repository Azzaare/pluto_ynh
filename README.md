# Pluto.jl - YunoHost package

Pluto.jl is a reactive notebook environment for Julia. This package deploys Pluto
behind the YunoHost portal with access control managed by YunoHost permissions.

## Notes

- This package requires `julia_ynh` to be installed first.
- Multi-instance is supported.
- Access is managed from YunoHost permissions; the tile appears only for authorized users/groups.

Julia package installation and updates repair the shared runtime and local cache
permissions on exit, including failed operations. The shared Juliaup launcher is
retained. The package uses Julia YunoHost's common permission routine when
installed, with an identical bundled fallback for earlier Julia YunoHost releases.
Notebook data is not removed by this packaging update.
