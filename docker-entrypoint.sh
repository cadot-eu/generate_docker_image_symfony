#!/bin/bash
set -e

# Démarrer le worker Messenger en arrière-plan
php /app/bin/console messenger:consume async --time-limit=3600 --memory-limit=128M &

# Démarrer Apache en avant-plan (permet de garder le conteneur en vie)
exec apache2-foreground
