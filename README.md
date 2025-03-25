# 🐳 Script de Construction Docker Personnalisé 

## 🚀 Fonctionnalités Principales

- 🛠️ Construction automatisée d'images Docker pour projets Symfony
- 🔧 Personnalisation flexible des extensions PHP
- 💾 Mémorisation et reprise des configurations précédentes
- 🏗️ Gestion des modes développement (dev) et production (prod)
- 📦 Génération dynamique du nom de l'image basé sur les configurations

## 🔍 Utilisation Rapide

```bash
# Construction standard
./build.sh

# Mode verbose
./build.sh -v

# Sans cache
./build.sh -s
```

## ✨ Fonctions Interactives

1. Choix du mode environnement (dev/prod)
2. Sélection personnalisée des extensions PHP
3. Ajout d'extensions supplémentaires
4. Option de sauvegarde de la configuration

## 💡 Configuration Persistante

Le script mémorise vos choix dans `~/.docker-build-config.conf` pour une réutilisation facile lors des prochains builds.
