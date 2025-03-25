#!/bin/bash
# Définir un mode strict pour la robustesse du script
set -euo pipefail

# Chemin du fichier de configuration
CONFIG_FILE="$HOME/.docker-build-config.conf"

# Fonction de gestion des erreurs
error_exit() {
    echo "Erreur: $1" >&2
    exit 1
}

# Fonction pour sauvegarder la configuration
save_config() {
    cat > "$CONFIG_FILE" << EOF
ENV_MODE=$env_mode
ENABLED_EXTENSIONS=$enabled_extensions
AUTRES_EXTENSIONS=$autres_extensions
EOF
    echo "Configuration sauvegardée dans $CONFIG_FILE"
}

# Fonction pour charger la dernière configuration
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        echo "Une configuration précédente a été trouvée :"
        cat "$CONFIG_FILE"
        read -p "Voulez-vous la réutiliser ? (O/N) " -r -e -i "O" response
        if [[ "$response" =~ ^[Oo]$ ]]; then
            # Charger la configuration précédente
            source "$CONFIG_FILE"
            echo "Configuration chargée :"
            echo "Mode d'environnement : $ENV_MODE"
            echo "Extensions PHP : ${ENABLED_EXTENSIONS:-Aucune}"
            echo "Autres extensions : ${AUTRES_EXTENSIONS:-Aucune}"
            
            env_mode="$ENV_MODE"
            enabled_extensions="${ENABLED_EXTENSIONS:-}"
            autres_extensions="${AUTRES_EXTENSIONS:-}"
        fi
    fi
}

# Gestion des arguments
NO_CACHE="--no-cache"
env_mode="" # Initialiser sans valeur par défaut
verbose=false

# Vérifier si l'option -v ou -s est activée
while getopts "vs" opt; do
    case $opt in
        v)
            verbose=true
        ;;
        s)
            NO_CACHE=""
        ;;
        *)
            echo "Usage: $0 [-v] [-s]"
            exit 1
        ;;
    esac
done

# Charger la dernière configuration si elle existe
load_config

# Demander à l'utilisateur de choisir dev ou prod si non défini
if [[ -z "${env_mode:-}" ]]; then
    echo "Choisissez l'environnement :"
    select env_choice in "dev" "prod"; do
        case $env_choice in
            dev)
                env_mode="dev"
                break
            ;;
            prod)
                env_mode="prod"
                break
            ;;
            *)
                echo "Choix invalide. Veuillez sélectionner 1 pour 'dev' ou 2 pour 'prod'."
            ;;
        esac
    done
fi

# Liste des extensions PHP
options=("amqp" "gd" "geoip" "gmagick" "gnupg" "imagick" "mongodb" "mysqli" "pdo_mysql" "pdo_pgsql" "redis" "snappy" "tidy" "uploadprogress" "yaml")

# Si les extensions ne sont pas déjà définies, demander la sélection
if [[ -z "${enabled_extensions:-}" ]]; then
    echo "Choisissez les modules à installer (entrez les numéros séparés par des espaces, ou appuyez sur 'Entrée' pour ignorer) :"
    for i in "${!options[@]}"; do
        echo "$((i+1))) ${options[$i]}"
    done
    
    # Lire la sélection des modules PHP à installer
    read -p "Sélectionnez les options PHP à installer (ex: 1 3 5 pour AMQP, GeoIP et MongoDB) : " selections
    
    # Construire la chaîne des extensions PHP sélectionnées
    enabled_extensions=""
    for selection in $selections; do
        if [[ "$selection" -ge 1 && "$selection" -le ${#options[@]} ]]; then
            ext="${options[$((selection-1))]}"
            enabled_extensions="${enabled_extensions}${enabled_extensions:+,}${ext}"
            echo "$ext activé"
        else
            echo "Option $selection invalide, ignorée."
        fi
    done
fi

# Si les autres extensions ne sont pas déjà définies, demander la sélection
if [[ -z "${autres_extensions:-}" ]]; then
    # Demander les extensions supplémentaires (comme LaTeX et Chromium)
    echo "Sélectionnez les extensions supplémentaires (latex, chromium) à installer (entrez les noms séparés par des virgules, ou appuyez sur 'Entrée' pour ignorer) :"
    read -p "Autres extensions (par ex: latex,chromium) : " autres_extensions
fi

# Créer le nom de l'image
image_name="symfonyMick"
image_name=$(echo "$image_name" | tr '[:upper:]' '[:lower:]')

# Ajouter le mode de l'environnement (dev ou prod)
if [[ "$env_mode" == "dev" ]]; then
    image_name="${image_name}-dev"
    elif [[ "$env_mode" == "prod" ]]; then
    image_name="${image_name}-prod"
else
    error_exit "Le mode d'environnement doit être 'dev' ou 'prod'."
fi

# Ajouter les extensions activées et les autres
if [[ -n "$enabled_extensions" ]]; then
    image_name="${image_name}_$(echo "$enabled_extensions" | tr ',' '-')"
fi
if [[ -n "$autres_extensions" ]]; then
    image_name="${image_name}_$(echo "$autres_extensions" | tr ',' '-')"
fi

save_config

# Affichage des options sélectionnées
echo "Extensions PHP activées: ${enabled_extensions:-Aucune}"
echo "Autres extensions activées: ${autres_extensions:-Aucune}"

# Commande de construction Docker avec les 3 arguments
echo "Build lancé avec ENABLED_EXTENSIONS=\"$enabled_extensions\", AUTRES_EXTENSIONS=\"$autres_extensions\", MODE=\"$env_mode\" , nom de l'image \"$image_name\" et USER_ID=$USER et GROUP_ID=$USER"

# Définir l'option --progress=plain si l'option -v est activée
progress_option=""
if [ "$verbose" = true ]; then
    progress_option="--progress=plain"
fi

# Construire l'image Docker
docker build $progress_option $NO_CACHE \
--build-arg ENABLED_EXTENSIONS="$enabled_extensions" \
--build-arg AUTRES_EXTENSIONS="$autres_extensions" \
--build-arg MODE="$env_mode" \
--build-arg USER_ID=$(id -u) \
--build-arg GROUP_ID=$(id -g) \
-t "$image_name" .

# Afficher le nom de l'image créée
echo "Image Docker créée : $image_name"