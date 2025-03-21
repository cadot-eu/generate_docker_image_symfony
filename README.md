# 🐳 Script Docker pour la Construction d'Images Symfony

Bienvenue dans le projet de construction d'images Docker pour une application Symfony ! Ce script vous permet de créer une image Docker personnalisée en fonction de l'environnement (dev ou prod) et des extensions PHP que vous souhaitez inclure.

## 📌 Table des matières

1. [Description](#description)
2. [Installation](#installation)
3. [Utilisation](#utilisation)
4. [Options de Construction](#options-de-construction)
5. [Contribuer](#contribuer)
6. [Licence](#licence)

## 📝 Description

Ce script Bash vous permet de construire une image Docker pour une application Symfony avec des modules PHP personnalisés. Vous pouvez spécifier l'environnement (`dev` ou `prod`), sélectionner les extensions PHP à inclure, et ajouter des extensions supplémentaires comme **LaTeX** ou **Chromium**.

Une fois créé il ne vous reste plus qu'à la mettre dans votre docker-compose à image: nom de l'image.

### Fonctionnalités

- 🛠️ **Choisir l'environnement** : Développer pour `dev` ou déployer en `prod`.
- ⚙️ **Sélectionner les extensions PHP** : Inclure des extensions comme `amqp`, `gd`, `redis`, etc.
- 🖥️ **Ajouter des extensions supplémentaires** : Comme `latex` et `chromium`.
- 🏗️ **Construire l'image Docker** avec les options sélectionnées.

## 🛠️ Installation

Assurez-vous que vous avez installé Docker sur votre machine avant de continuer.

1. Clonez ce dépôt :

   ```bash
   git clone https://github.com/cadot-eu/generate_docker_image_symfony.git
   cd generate_docker_image_symfony
   ```

    Assurez-vous que Docker est en cours d'exécution :

    ` docker --version `

## 🚀 Utilisation

Lancer la construction de l'image Docker

Pour construire l'image Docker, exécutez simplement le script :

./build-image.sh

Options disponibles
-v : Pour activer le mode verbose (affiche plus de détails pendant la construction).

## 🚀 Étapes de Construction

- Choisissez l'environnement (dev ou prod).
- Sélectionnez les extensions PHP à installer.
- Ajoutez des extensions supplémentaires comme latex ou chromium si nécessaire.
- Le script construira l'image Docker avec les options choisies.

Enfin, il construira l'image Docker en fonction des choix effectués.

🤝 Contribuer

Les contributions sont les bienvenues ! Si vous avez des idées d'améliorations ou des corrections de bugs, suivez ces étapes :

- Forkez ce dépôt.
- Créez une branche pour vos modifications (git checkout -b feature/nouvelle-fonction).
- Faites vos modifications.
- Commitez vos changements (git commit -m 'Ajout de ma nouvelle fonctionnalité').
- Poussez la branche (git push origin feature/nouvelle-fonction).
- Ouvrez une Pull Request pour discuter de vos changements.

📄 Licence

Ce projet est sous licence MIT.

Si vous avez des questions ou avez besoin de support, n'hésitez pas à me contacter à : <mgenerate@cadot.eu>.
