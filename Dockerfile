# Stage de build - uniquement pour l'installateur d'extensions
FROM php:8.2-fpm-alpine AS builder

# Message de démarrage
RUN echo "----------------------------------------------------------------" && \
    echo "🚀 ÉTAPE 1: PRÉPARATION DE L'ENVIRONNEMENT DE BUILD" && \
    echo "----------------------------------------------------------------"

# Installation de l'installateur d'extensions
ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

# Stage wkhtmltopdf
FROM surnet/alpine-wkhtmltopdf:3.20.2-0.12.6-full AS wkhtmltopdf

# Stage final
FROM php:8.2-fpm-alpine

# Déclaration des arguments avec valeurs par défaut
ARG ENABLED_EXTENSIONS=""
ARG AUTRES_EXTENSIONS=""
ARG MODE="prod"

# Message de démarrage du stage final
RUN echo "----------------------------------------------------------------" && \
    echo "🚀 ÉTAPE 2: CONSTRUCTION DE L'IMAGE FINALE" && \
    echo "----------------------------------------------------------------"

# Définir MODE comme variable d'environnement
ENV MODE=$MODE \
    SYMFONY_VERSION=7 \
    COMPOSER_ALLOW_SUPERUSER=1 \
    PATH=/var/www/html/vendor/bin:$PATH

# Copie de l'installateur d'extensions depuis le builder
COPY --from=builder /usr/local/bin/install-php-extensions /usr/local/bin/

# Copie des fichiers de configuration
COPY ./BuildConfig /tmp/BuildConfig

# Installation des dépendances minimales pour wkhtmltopdf
RUN apk add --no-cache \
    libstdc++ \
    libx11 \
    libxrender \
    libxext \
    fontconfig \
    freetype

# Copie des binaires wkhtmltopdf depuis l'image surnet
COPY --from=wkhtmltopdf /bin/wkhtmltopdf /usr/local/bin/wkhtmltopdf
COPY --from=wkhtmltopdf /lib/libwkhtmltox* /lib/

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
    # Installation des dépendances système
    echo "⏳ Installation des dépendances système..." && \
    apk add --no-cache nginx supervisor git && \
    echo "✅ Dépendances système installées" && \
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
RUN echo "----------------------------------------------------------------" && \
    echo "📁 COPIE DES FICHIERS DE CONFIGURATION" && \
    echo "----------------------------------------------------------------"

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

# Message avant la copie du code
RUN echo "----------------------------------------------------------------" && \
    echo "📦 COPIE DU CODE SOURCE" && \
    echo "----------------------------------------------------------------"

# Répertoire de travail et copie du code
WORKDIR /app
COPY . /app

# Message final
RUN echo "----------------------------------------------------------------" && \
    echo "✨ IMAGE DOCKER CONSTRUITE AVEC SUCCÈS" && \
    echo "----------------------------------------------------------------"

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
