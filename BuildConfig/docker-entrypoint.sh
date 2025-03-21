#!/bin/sh
set -e

# Exécuter les commandes pour installer/mettre à jour Symfony si nécessaire
if [ "${1#-}" != "$1" ]; then
    set -- php-fpm "$@"
fi

if [ "$1" = 'php-fpm' ] || [ "$1" = 'bin/console' ]; then
    # Installer les dépendances si nécessaire
    if [ ! -d vendor ]; then
        composer install --prefer-dist --no-progress --no-interaction
    fi
    
    # Mettre à jour la base de données si nécessaire
    php bin/console doctrine:migrations:migrate --no-interaction || true
    
    # Vider le cache
    php bin/console cache:clear || true
fi

exec "$@"