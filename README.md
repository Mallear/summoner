Projet Summoner - Puzle tool list
---

# Summoner

Summoner est un projet de déploiement d'une stack générique d'outils. Il a pour but de permettre le déploiement d'un environnement de travail aussi simplement qu'en pressant un bouton.

## Les outils

Chacun des outils suivants sont actuellement disponibles dans le dossier `Setup` et documenté dans le dossier `Wiki` :
* [Nginx & letsencrypt](https://gitlab.com/puzle-project/Summoner/blob/master/Wiki/NginxContainer.md)
* Docker documentation
* [Ghost](https://gitlab.com/puzle-project/Summoner/blob/master/Wiki/GhostContainer.md)
* Wordpress
* Wekan
* Mattermost
* [Nextcloud](https://gitlab.com/puzle-project/Summoner/blob/master/Wiki/NextcloudContainer.md)
* [Gitlab & Gitlab CI](https://gitlab.com/puzle-project/Summoner/blob/master/Wiki/GitlabContainer.md)

## Projet ***

`***` est le nom du script de sauvegarde des bases de données utilisées par les outils mis en place par `Summoner`. Concernant ce projet, deux documentations existes :
* La [première](https://gitlab.com/puzle-project/Summoner/blob/master/Wiki/Databases) concerne les bases de données à proprement parler et aborde les méthodes de dump et backup des données.
* La [seconde](https://gitlab.com/puzle-project/Summoner/blob/master/Wiki/SaveProject.md) documente directement les scripts de sauvegarde utilisés.

## Configuration
### Main project

La configuration du projet est effectué via le fichier `.env` à la racine du `Setup`. Pour ce faire, copier le fichier `.env_default` et remplissez le comme souhaité.

## FAQ

Un document FAQ est accessible [ici](../blob/master/Wiki/FAQ.md). Il ressence tout les problèmes rencontrés relatifs à Docker ou certains containers et les solutions trouvées.
