Projet Summoner - Puzle tool list
---

# Summoner

Summoner est un projet de déploiement d'une stack générique d'outils. Il a pour but de permettre le déploiement d'un environnement de travail aussi simplement qu'en pressant un bouton.

## Installation de Summoner

Un script d'installation, `summoner-setup`, est en cours de réalisation.

## Configuration
### Règles de nommage <a id="regle-nommage"></a>
Afin de facilité l'automatisation de l'entretien du système, des règles de nommage doivent être respectées.

**Nommer son conteneur**  
Par défaut, Docker nomme les conteneurs construits via compose selon un motif tel que `<directory>_<service>_1`. Cela pose problème lors de l'entretient du l'environnement (sauvegarde des données, dump des bases ...).

Pour cela, il est nécessaire de nommer manuellement les conteneurs générés. Pour cela, il suffit d'ajouter les options suivantes :
* `container_name: <name>` dans un docker compose
* `--name <name>` en lançant directement le conteneur

**Application**  
Un conteneur d'application doit être nommé comme suit :  
  > `<application>-<domain>`

**Bases de données**  
Un conteneur contenant une base de données doit être nommé comme suit :  
  > `<database_type>-<application>-<domain>`

`Database_type :
* mongodb
* mysql
* mariadb
* postgresql`

**Service supplémentaire**  
Chaque service complémentaire à une application, si aucun service centralisé n'est utilisé, devra être contenu dans un docker nommé avec le même schéma que pour les bases de données :  
`<service>-<application>-<domain>`

_Exemple :_  
Prenons pour example un conteneur Gitlab accessible sur le nom de domaine `example.com`, nécessitant une base de donnée PostreSQL et un serveur Redis. Les trois conteneurs créés seront nommés ainsi :
* `gitlab-example.com` pour l'application principale
* `redis-gitlab-example.com` pour le serveur redis
* `postgresql-gitlab-example.com` pour la base de données


### Configuration des containers
La configuration du projet est effectué via un fichier `.env` situé à la racine du `Setup`. Ce fichier contient les variables prenant part à la configuration des fichier `docker-compose`.  
Pour définir ce fichier, il suffit de copier le fichier `.env_default` et le remplir en conséquence.

Ces variables permettent de simplifier la création d'une configuration d'un serveur à l'autre.


## Les minions

Chacun des outils suivants ainsi que sa documentation peut être trouvé dans le répo le concernant :
* [Nginx & letsencrypt](https://gitlab.com/puzle-project/Summoner-nginx)
* Docker documentation
* [Ghost](https://gitlab.com/puzle-project/Summoner-ghost)
* [Wordpress](https://gitlab.com/puzle-project/Summoner-wordpress)
* [Wekan](https://gitlab.com/puzle-project/Summoner-wekan)
* [Mattermost](https://gitlab.com/puzle-project/Summoner-mattermost)
* [Nextcloud](https://gitlab.com/puzle-project/Summoner-nextcloud)
* [Gitlab & Gitlab CI](https://gitlab.com/puzle-project/Summoner-gitlab)

## Dump des bases de données

`summoner-database-dump` est le script de sauvegarde des bases de données utilisées par les outils mis en place par `Summoner`. Concernant ce projet, deux documentations existes :
* La [première](https://gitlab.com/puzle-project/Summoner/blob/master/Wiki/Databases.md) concerne les bases de données à proprement parler et aborde les méthodes de dump et backup des données.
* La [seconde](https://gitlab.com/puzle-project/Summoner/blob/master/Wiki/summoner-database-dump.md) documente directement les scripts de sauvegarde utilisés.

## Backup des bases de données
_Stay tuned_

## Backup des données
_Stay tuned_


## FAQ

Un document FAQ est accessible [ici](../blob/master/Wiki/FAQ.md). Il ressence tout les problèmes rencontrés relatifs à Docker ou certains containers et les solutions trouvées.
