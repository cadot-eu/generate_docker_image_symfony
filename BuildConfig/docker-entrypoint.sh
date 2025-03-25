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

# gestion répertoire var
if [ ! -d var ]; then
    log_warn "Création du répertoire var..."
    mkdir var
    mkdir var/log
    chmod -R 775 var/
fi



# Installation des dépendances si nécessaire
if [ ! -d vendor ]; then
    log_warn "Installation des dépendances via Composer..."
    if composer install --prefer-dist --no-progress --no-interaction; then
        log_success "Dépendances installées avec succès"
    else
        log_error "Échec de l'installation des dépendances"
        
    fi
fi


# importmap install
log_warn "Installation de importmap..."
php bin/console importmap:install --no-interaction || {
    log_error "Échec de l'installation de importmap"
    
}

# Mise à jour de la base de données
log_warn "Mise à jour de la base de données..."
php bin/console doctrine:schema:update --no-interaction || {
    log_error "Erreur durant la mise à jour de la base de données"
    
}

# Gestion du cache Symfony
log_warn "Gestion du cache Symfony..."
{
    php bin/console cache:clear --no-warmup && \
    php bin/console cache:warmup
    } || {
    log_error "Erreur durant la gestion du cache"
    
}

# Compilation des assets si la commande existe
log_warn "Compilation des assets..."
if php bin/console | grep -q asset-map:compile; then
    php bin/console asset-map:compile --no-interaction || {
        log_error "Erreur durant asset-map:compile"
        
    }
else
    log_warn "Commande asset-map:compile non disponible - ignorée"
fi


# Création du raccourci sc pour Symfony Console
log_warn "Création du raccourci sc..."
cat > /usr/local/bin/sc <<'EOF'
#!/bin/sh
php /app/bin/console "$@"
EOF
chmod +x /usr/local/bin/sc


log_warn "Démarrage de Supervisord..."
exec "$@"

