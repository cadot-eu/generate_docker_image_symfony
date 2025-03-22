#!/bin/sh
set -e

echo "Entrée dans docker-entrypoint.sh"


if [ "${1#-}" != "$1" ]; then
    set -- php-fpm "$@"
fi

echo "Argument passé : $1"

#if [ "$1" = 'php-fpm' ] || [ "$1" = 'bin/console' ]; then
echo "Démarrage du service $1"

if [ ! -d vendor ]; then
    echo "Installation des dépendances via Composer..."
    composer install --prefer-dist --no-progress --no-interaction
fi

echo "Vider et réchauffer le cache..."
php bin/console cache:clear --no-warmup || true
php bin/console cache:warmup || true

chown -R www-data:www-data /app/var

php bin/console asset-map:compile --no-interaction || true


php bin/console cache:clear || true
#fi

alias sc="php bin/console"
cat > /bin/sc <<'EOF'
#!/bin/sh
php bin/console "$@"
EOF
chmod +x /bin/sc
# Lancer supervisord (assure-toi que supervisord est configuré)
exec /usr/bin/supervisord -c /etc/supervisord.conf
