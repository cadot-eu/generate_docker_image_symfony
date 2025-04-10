#!/bin/sh
set -e
#définition de log_success, log_error ..
log_success() {
    echo -e "\033[0;32m\033[1m  ${1:-Success}\033[0m \033[1;32m"
}
log_error() {
    echo -e "\033[1;31m  $(echo $1 | sed 's/.*/ & /')\033[0m"
}
log_warn() {
    echo -e "\033[1;33m  $(echo $1 | sed 's/.*/ & /')\033[0m"
}
# Démarrer le script
echo "Démarrage du script docker-entrypoint.sh"

# Vérifier que nous sommes dans le bon répertoire
if [ ! -f bin/console ]; then
    log_error "Le répertoire courant ne semble pas contenir une application Symfony!"
    
fi

git config --global --add safe.directory /app

# gestion répertoire var
if [ ! -d var ]; then
    log_warn "Création du répertoire var..."
    mkdir var
    mkdir var/log
fi

chmod -R 775 var
chown -R www-data:www-data var


# Installation des dépendances si nécessaire
log_warn "Installation des dépendances via Composer..."
if composer install --prefer-dist --no-progress --no-interaction; then
    log_success "Dépendances installées avec succès"
else
    log_error "Échec de l'installation des dépendances"
    
fi


# importmap install
if [ ! -f public/vendor/importmap ]; then
    log_warn "Installation de importmap..."
    php bin/console importmap:install --no-interaction || {
        log_error "Échec de l'installation de importmap"
        
    }
fi

# Mise à jour de la base de données
log_warn "Mise à jour de la base de données..."
php bin/console doctrine:schema:update --no-interaction || {
    log_error "Erreur durant la mise à jour de la base de données"
    
}

# Gestion du cache Symfony
log_warn "Gestion du cache Symfony..."
if [ "$MODE" = "dev" ]; then
    php bin/console cache:clear || {
        log_error "Erreur durant la suppression du cache"
    }
else
    php bin/console cache:clear --no-warmup && \
    php bin/console cache:warmup || {
        log_error "Erreur durant la mise en cache"
    }
fi


# Compilation des assets si la commande existe

log_warn "Compilation des assets..."
if php bin/console | grep -q asset-map:compile; then
    php bin/console asset-map:compile --no-interaction || {
        log_error "Erreur durant asset-map:compile"
    }
else
    log_warn "Commande asset-map:compile non disponible - ignorée"
fi

#installion de php flasher
log_warn "Installation de php flasher..."
if [ ! -f public/vendor/flasher ] && [ -d vendor/php-flasher ]; then
    log_warn "Installation de php flasher..."
    php bin/console flasher:install
fi

#permission www-data sur public
log_warn "Permission www-data sur public..."
chown -R www-data:www-data public




# Création du raccourci sc pour Symfony Console
log_warn "Création du raccourci sc..."
cat > /usr/local/bin/sc <<'EOF'
#!/bin/sh
php /app/bin/console "$@"
EOF
chmod +x /usr/local/bin/sc

# Création du raccourci translationUpdateFr
log_warn "Création du raccourci translationUpdateFr..."
cat > /usr/local/bin/translationUpdateFr <<'EOF'
#!/bin/sh
php bin/console translation:extract --force --no-fill fr --format=yaml
EOF
chmod +x /usr/local/bin/translationUpdateFr


log_warn "Démarrage de Supervisord..."
exec "$@"

