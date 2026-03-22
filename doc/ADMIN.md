# Admin guide

## Access control

Pluto is only reachable through the YunoHost portal. By default, no one has access.
Grant access from the app permissions in webadmin.
Admins can always manage permissions from webadmin, even when no one is allowed yet.
The portal tile appears only for users/groups that are granted access.

Pluto is configured without a secret token (`require_secret_for_access=false`) because
access is gated by YunoHost authentication. Links still require confirmation
(`require_secret_for_open_links=true`).

## Notebooks storage

Each instance has its own notebooks directory:

`/var/lib/__APP__/notebooks`

Users can upload and download notebooks from the Pluto UI.
