Projet Summoner - Puzle tool list
---

# Summoner

Summoner est un projet de déploiement d'une stack générique d'outils. Il a pour but de permettre le déploiement d'un environnement de travail aussi simplement qu'en pressant un bouton.

## Les outils

Chacun des outils suivants sont actuellement disponibles dans le dossier `Setup` :
* [Nginx & letsencrypt](https://gitlab.com/puzle-project/Summoner/blob/master/Wiki/NginxContainer.md)
* Docker documentation
* Ghost
* Wordpress
* Wekan
* Mattermost
* Nextcloud
* [Gitlab & Gitlab CI](https://gitlab.com/puzle-project/Summoner/blob/master/Wiki/GitlabContainer.md)

La documentation de chacun de ces outils est détaillée dans le dossier `Wiki`.

## Configuration

La configuration du projet est effectué via le fichier .env à la racine du `Setup`. Pour ce faire, copier le fichier `.env_default` et remplissez le comme souhaité.
