#!/bin/sh
set -e


# Démarrer le script
echo "Démarrage du script docker-entrypoint.sh"

# Vérifier que nous sommes dans le bon répertoire
if [ ! -f bin/console ]; then
    log_error "Le répertoire courant ne semble pas contenir une application Symfony!"
    exit 1
fi

# Gestion des arguments
if [ "${1#-}" != "$1" ]; then
    set -- php-fpm "$@"
fi

echo "Commande passée: $@"

# Installation des dépendances si nécessaire
if [ ! -d vendor ]; then
    log_warn "Installation des dépendances via Composer..."
    if composer install --prefer-dist --no-progress --no-interaction; then
        log_success "Dépendances installées avec succès"
    else
        log_error "Échec de l'installation des dépendances"
        exit 1
    fi
fi

# Gestion du cache Symfony
log_warn "Gestion du cache Symfony..."
{
    php bin/console cache:clear --no-warmup && \
    php bin/console cache:warmup
    } || {
    log_error "Erreur durant la gestion du cache"
    exit 1
}

# Compilation des assets si la commande existe
log_warn "Compilation des assets..."
if php bin/console | grep -q asset-map:compile; then
    php bin/console asset-map:compile --no-interaction || {
        log_error "Erreur durant asset-map:compile"
        exit 1
    }
else
    log_warn "Commande asset-map:compile non disponible - ignorée"
fi

# Définir les permissions
log_warn "Configuration des permissions..."
chown -R www-data:www-data var

# Création du raccourci sc pour Symfony Console
log_warn "Création du raccourci sc..."
cat > /usr/local/bin/sc <<'EOF'
#!/bin/sh
php /app/bin/console "$@"
EOF
chmod +x /usr/local/bin/sc

# Gestion de supervisord
if [ -x "$(command -v supervisord)" ]; then
    echo "Démarrage de supervisord..."
    if [ -f /etc/supervisord.conf ]; then
        # Démarrer supervisord sans prendre le contrôle du processus principal
        /usr/bin/supervisord -c /etc/supervisord.conf &
    else
        log_error "Fichier de configuration supervisord.conf introuvable"
    fi
else
    log_warn "supervisord n'est pas installé - ignoré"
fi

# Exécuter la commande principale
log_success "Exécution de la commande principale: $@"
exec "$@"