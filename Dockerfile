# Stage de build - uniquement pour l'installateur d'extensions
FROM php:8.2-fpm-alpine AS builder

# Message de démarrage
RUN echo "----------------------------------------------------------------"
RUN echo "🚀 ÉTAPE 1: PRÉPARATION DE L'ENVIRONNEMENT DE BUILD"
RUN echo "----------------------------------------------------------------"

# Installation de l'installateur d'extensions
ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

# Stage final
FROM php:8.2-fpm-alpine

# Déclaration des arguments avec valeurs par défaut
ARG ENABLED_EXTENSIONS=""
ARG AUTRES_EXTENSIONS=""
ARG MODE="prod"

# Message de démarrage du stage final
RUN echo "----------------------------------------------------------------"
RUN echo "🚀 ÉTAPE 2: CONSTRUCTION DE L'IMAGE FINALE"
RUN echo "----------------------------------------------------------------"

# Définir MODE comme variable d'environnement
ENV MODE=$MODE \
    SYMFONY_VERSION=7 \
    COMPOSER_ALLOW_SUPERUSER=1 \
    PATH=/var/www/html/vendor/bin:$PATH

# Copie de l'installateur d'extensions depuis le builder
COPY --from=builder /usr/local/bin/install-php-extensions /usr/local/bin/

# Copie des fichiers de configuration
COPY ./BuildConfig /tmp/BuildConfig

# Installation de toutes les extensions dans l'image finale
RUN echo "----------------------------------------------------------------" && \
    echo "🔧 INSTALLATION DES EXTENSIONS PHP" && \
    echo "----------------------------------------------------------------" && \
    echo "Extensions activées: $ENABLED_EXTENSIONS" && \
    echo "Autres extensions: $AUTRES_EXTENSIONS" && \
    echo "Mode: $MODE" && \
    \
    # Installation des extensions PHP de base
    echo "⏳ Installation des extensions de base..." && \
    install-php-extensions @composer apcu intl memcached opcache zip gnupg && \
    echo "✅ Extensions de base installées avec succès" && \
    \
    # Installation des extensions spécifiées si présentes
    if [ -n "$ENABLED_EXTENSIONS" ]; then \
        echo "⏳ Installation des extensions personnalisées: $ENABLED_EXTENSIONS" && \
        install-php-extensions $(echo $ENABLED_EXTENSIONS | tr ',' ' ') && \
        echo "✅ Extensions personnalisées installées avec succès"; \
    else \
        echo "ℹ️ Aucune extension personnalisée à installer"; \
    fi && \
    \
    # Installation conditionnelle de Xdebug
    if [ "$MODE" = "dev" ]; then \
        echo "⏳ Mode DEV détecté - Installation de Xdebug..." && \
        install-php-extensions xdebug && \
        # Copie du fichier de configuration Xdebug
        echo "⏳ Copie du fichier de configuration Xdebug..." && \
        #cat "/tmp/BuildConfig/xdebug.ini" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
        echo "✅ Configuration Xdebug installée"; \
    else \
        echo "ℹ️ Mode PROD détecté - Xdebug non installé"; \
    fi && \
    \
    # Installation des dépendances système
    echo "⏳ Installation des dépendances système..." && \
    apk add --no-cache nginx supervisor git && \
    echo "✅ Dépendances système installées" && \
    \
    # Installation conditionnelle de Chromium
    if echo "$AUTRES_EXTENSIONS" | grep -q "\bchromium\b"; then \
        echo "⏳ Installation de Chromium..." && \
        apk add --no-cache chromium && \
        echo "✅ Chromium installé avec succès"; \
    fi && \
    \
    # Installation conditionnelle de LaTeX
    if echo "$AUTRES_EXTENSIONS" | grep -q "\blatex\b"; then \
        echo "⏳ Installation de LaTeX..." && \
        apk add --no-cache texlive && \
        echo "✅ LaTeX installé avec succès"; \
    fi && \
    \
    # Création des répertoires nécessaires
    echo "⏳ Création des répertoires..." && \
    mkdir -p /app/var/log/supervisor /var/run/supervisor /etc/supervisor/conf.d && \
    chmod -R 777 /app/var/log/supervisor /var/run/supervisor && \
    echo "✅ Répertoires créés" && \
    \
    # Alias Symfony console
    echo 'alias sc="php /app/bin/console"' >> ~/.bashrc && \
    \
    # Nettoyage
    echo "🧹 Nettoyage des fichiers temporaires..." && \
    rm -rf /tmp/* /var/cache/apk/* && \
    echo "✅ Nettoyage terminé"

# Message avant la copie des fichiers de configuration
RUN echo "----------------------------------------------------------------"
RUN echo "📁 COPIE DES FICHIERS DE CONFIGURATION"
RUN echo "----------------------------------------------------------------"

# Copie des fichiers de configuration
COPY ./BuildConfig/nginx.conf /etc/nginx/http.d/default.conf
COPY ./BuildConfig/php.ini /usr/local/etc/php/php.ini
COPY ./BuildConfig/supervisord.conf /etc/supervisord.conf

COPY ./BuildConfig /tmp/BuildConfig
# Configuration conditionnelle de PHP
RUN echo "⏳ Application de la configuration PHP pour le mode $MODE..." && \
    if [ -f "/tmp/BuildConfig/php_${MODE}.ini" ]; then \
        cat "/tmp/BuildConfig/php_${MODE}.ini" >> /usr/local/etc/php/php.ini && \
        echo "✅ Configuration PHP du mode $MODE appliquée"; \
    else \
        echo "ℹ️ Aucun fichier de configuration spécifique trouvé pour le mode $MODE"; \
    fi 
    # && \
    #rm -rf /tmp/BuildConfig

# Message avant la copie du code
RUN echo "----------------------------------------------------------------"
RUN echo "📦 COPIE DU CODE SOURCE"
RUN echo "----------------------------------------------------------------"

# Répertoire de travail et copie du code
WORKDIR /app
RUN mkdir -p /var/log/supervisor

# Message final
RUN echo "----------------------------------------------------------------"
RUN echo "✨ IMAGE DOCKER CONSTRUITE AVEC SUCCÈS"
RUN echo "----------------------------------------------------------------"

# Répertoire de travail et copie du code
WORKDIR /app

# Copier le script d'entrypoint dans l'image Docker
COPY BuildConfig/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

# Rendre le script exécutable
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Définir le script comme point d'entrée du conteneur
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

# Créer le répertoire pour les logs de supervisord
RUN mkdir -p /var/log/supervisor

# Définir supervisord comme processus principal à lancer
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
