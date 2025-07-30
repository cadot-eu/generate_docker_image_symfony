# Générateur d'image Docker Symfony

## Présentation

Ce projet permet de générer facilement une image Docker optimisée pour des applications Symfony, avec une configuration flexible et automatisée. Il inclut un script interactif (`build.sh`) qui vous guide dans la création d'une image adaptée à vos besoins (environnement, extensions PHP, outils supplémentaires, etc.).

## Fonctionnalités principales

- **Génération d'image Docker Symfony 7+** (compatible PHP 8.2 FPM Alpine)
- **Script d'entrypoint avancé** : installation automatique des dépendances, gestion des permissions, initialisation du cache, des assets, de la base de données, etc.
- **Support multi-environnement** : choix entre `dev` et `prod` lors de la génération
- **Sélection interactive des extensions PHP** (amqp, gd, redis, etc.)
- **Ajout d'outils système optionnels** : LaTeX, Python, Chromium...
- **Gestion automatique des permissions** pour éviter les erreurs Symfony classiques
- **Supervisord** pour gérer PHP-FPM, Nginx et les workers Messenger
- **Alias pratiques** pour la console Symfony et la mise à jour des traductions

## Options du script `build.sh`

- `-v` : mode verbeux (affiche la progression détaillée du build Docker)
- `-s` : build rapide (utilise le cache Docker si disponible)

Lors de l'exécution, le script vous demandera :
- Le mode d'environnement (`dev` ou `prod`)
- Les extensions PHP à activer (sélection par numéro)
- Les outils système supplémentaires à installer (latex, python, chromium...)

La configuration est sauvegardée pour les prochains builds.

## Comment générer l'image Docker

1. Rendez-vous à la racine du projet
2. Rendez le script exécutable si besoin :
   ```bash
   chmod +x build.sh
   ```
3. Lancez la génération :
   ```bash
   ./build.sh
   ```
   (Ajoutez `-v` pour le mode verbeux, `-s` pour forcer l'utilisation du cache)

L'image générée portera un nom explicite selon vos choix (ex : `symfonymick-dev_gd_redis_python`).

## Ce que l'image créée peut faire

- Démarrer un environnement Symfony complet (PHP-FPM, Nginx, Messenger worker)
- Initialiser automatiquement le projet (dépendances, cache, base, assets...)
- Gérer les permissions pour éviter les erreurs d'écriture (logs, sessions, cache)
- Fournir des outils prêts à l'emploi (wkhtmltopdf, LaTeX, Python, Chromium...)
- Exposer des alias pratiques pour la console Symfony

## Avantages de cette génération automatisée

- **Gain de temps** : plus besoin de modifier manuellement le Dockerfile ou les scripts d'init
- **Flexibilité** : chaque build peut être adapté à vos besoins (environnement, extensions, outils)
- **Reproductibilité** : la configuration est sauvegardée et réutilisable
- **Sécurité** : gestion stricte des permissions, pas de droits excessifs
- **Simplicité** : tout est guidé, même pour les débutants Docker/Symfony

## Avantages de l'image générée

- **Prête à l'emploi** pour le développement ou la production
- **Optimisée** (taille réduite, dépendances minimales)
- **Multi-process** (PHP-FPM, Nginx, Messenger worker supervisés)
- **Compatible CI/CD** (build scriptable, configuration versionnable)
- **Extensible** (ajout facile d'extensions ou d'outils)
- **Robuste** (gestion automatique des erreurs courantes Symfony)

---

Pour toute question ou suggestion, ouvrez une issue ou contactez le mainteneur du projet.
