# nginx

Configuration des frontaux web pour les 3 machines logiques.

## Sous-dossiers

- `machine1/`: config Nginx + page statique de la machine 1.
- `machine2/`: config Nginx + page statique de la machine 2.
- `machine3/`: config Nginx + page statique de la machine 3.

Chaque `default.conf` reverse-proxyfie `/api/` vers l'API correspondante.
