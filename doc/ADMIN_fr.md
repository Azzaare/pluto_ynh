# Guide d'administration

## Contrôle d'accès

Pluto n'est accessible qu'à travers le portail YunoHost. Par défaut, personne n'a accès.
Accordez l'accès depuis les permissions de l'app dans le webadmin.
Les admins peuvent toujours gérer les permissions depuis le webadmin, même si personne n'a accès.
La tuile du portail n'apparaît que pour les utilisateurs/groupes autorisés.

Pluto est configuré sans jeton secret (`require_secret_for_access=false`) car
l'accès est protégé par l'authentification YunoHost. Les liens demandent tout de même
une confirmation (`require_secret_for_open_links=true`).

## Stockage des notebooks

Chaque instance a son propre répertoire de notebooks :

`/var/lib/__APP__/notebooks`

Les utilisateurs peuvent importer et exporter des notebooks depuis l'interface Pluto.
