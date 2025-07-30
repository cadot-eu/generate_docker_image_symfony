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

## Nommage automatique des images Docker

L'image générée porte un nom explicite qui résume vos choix de build. La logique de nommage est la suivante :

```
symfonymick-<env>_<extensions-php>_<autres-extensions>
```

- `<env>` : `dev` ou `prod` selon l'environnement choisi
- `<extensions-php>` : liste des extensions PHP activées, séparées par un tiret (ex : `gd-redis`)
- `<autres-extensions>` : liste des outils système ajoutés, séparés par un tiret (ex : `python-chromium`)

**Exemple de nom généré :**

```
symfonymick-dev_gd_redis_python
```

Ce nom facilite l'identification rapide de l'environnement et des fonctionnalités incluses dans chaque image Docker générée.

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

## Processus supervisés dans l'image

L'image Docker démarre automatiquement plusieurs processus grâce à **supervisord** :

- **php-fpm** : serveur PHP pour Symfony
- **nginx** : serveur web HTTP
- **messenger-worker** : worker Symfony Messenger pour la gestion des files d'attente
- (Tous les autres process déclarés dans `/etc/supervisord.conf` ou `/app/*.conf`)

### Ajouter vos propres process supervisés

Vous pouvez ajouter facilement vos propres scripts ou services à superviser dans le conteneur Docker. Il suffit d'ajouter un fichier `.conf` dans `/app/` (ou de le copier dans l'image via le Dockerfile). Exemple :

```ini
[program:domotic-loop]
command=/bin/sh /app/Sync.sh
autostart=true
autorestart=true
stderr_logfile=/var/log/domotic-loop.err.log
stdout_logfile=/var/log/domotic-loop.out.log

[program:mqtt-listener]
command=/bin/sh /app/SyncMqtt.sh
autostart=true
autorestart=true
startsecs=10
stderr_logfile=/var/log/mqtt-listener.err.log
stdout_logfile=/var/log/mqtt-listener.out.log

[program:aggregate]
command=/bin/sh /app/AggregateLoop.sh
autostart=true
autorestart=true
startsecs=10
stderr_logfile=/var/log/AggregateLoop.err.log
stdout_logfile=/var/log/AggregateLoop.out.log
```

Déposez ce fichier (par exemple `myprocesses.conf`) dans `/app/` : il sera automatiquement pris en compte au démarrage du conteneur.

Vous pouvez ainsi superviser autant de scripts ou services que nécessaire (API, workers, synchronisations, etc.) dans le même conteneur Docker.

## Extensions PHP et outils système disponibles

Lors de l'exécution du script `build.sh`, vous pouvez choisir d'installer différentes extensions PHP et outils système. Voici un tableau récapitulatif :

| Nom                | Type      | Utilité principale                                 | Paramètre/Activation dans le script |
|--------------------|-----------|----------------------------------------------------|-------------------------------------|
| amqp               | PHP ext.  | Files d'attente RabbitMQ/AMQP                      | Sélection dans la liste             |
| gd                 | PHP ext.  | Manipulation d'images                              | Sélection dans la liste             |
| geoip              | PHP ext.  | Géolocalisation IP                                 | Sélection dans la liste             |
| gmagick            | PHP ext.  | Manipulation avancée d'images                      | Sélection dans la liste             |
| gnupg              | PHP ext.  | Chiffrement, signatures GPG                        | Sélection dans la liste             |
| imagick            | PHP ext.  | Manipulation avancée d'images                      | Sélection dans la liste             |
| mongodb            | PHP ext.  | Support MongoDB                                    | Sélection dans la liste             |
| mysqli             | PHP ext.  | Support MySQLi                                     | Sélection dans la liste             |
| pdo_mysql          | PHP ext.  | Support PDO MySQL                                  | Sélection dans la liste             |
| pdo_pgsql          | PHP ext.  | Support PDO PostgreSQL                             | Sélection dans la liste             |
| redis              | PHP ext.  | Cache, sessions, files d'attente Redis             | Sélection dans la liste             |
| sockets            | PHP ext.  | Manipulation bas niveau des sockets réseau         | Sélection dans la liste             |
| snappy             | PHP ext.  | Compression Snappy                                 | Sélection dans la liste             |
| tidy               | PHP ext.  | Nettoyage HTML/XML                                 | Sélection dans la liste             |
| uploadprogress     | PHP ext.  | Suivi de l'upload de fichiers                      | Sélection dans la liste             |
| yaml               | PHP ext.  | Manipulation de fichiers YAML                      | Sélection dans la liste             |
| latex              | Système   | Génération de PDF scientifiques                    | Ajouter dans "autres extensions"   |
| python             | Système   | Scripts Python, outils scientifiques               | Ajouter dans "autres extensions"   |
| chromium           | Système   | Navigateur headless pour tests, génération PDF     | Ajouter dans "autres extensions"   |
| wkhtmltopdf        | Système   | Génération de PDF à partir de HTML                 | Toujours présent                    |

### Comment les utiliser ?

- **Extensions PHP** : sélectionnez-les lors de l'exécution du script (ex : tapez `1 3 5` pour activer amqp, geoip, gnupg)
- **Outils système** : tapez leur nom (séparés par des virgules) à la question "Autres extensions" (ex : `latex,python,chromium`)
- **wkhtmltopdf** est toujours inclus par défaut

Vous pouvez combiner autant d'extensions que nécessaire pour adapter l'image à votre projet Symfony.

---

Pour toute question ou suggestion, ouvrez une issue ou contactez le mainteneur du projet.
