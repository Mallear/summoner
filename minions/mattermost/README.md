# Conteneur Mattermost
_Documentation du fichier [`docker-compose.yml`](docker-compose.yml) d'un conteneur pour une instance Mattermost_

Mattermost est une solution Slack-like de chat multi channel opensource. A la différence de [Slack](http://www.slack.com), aucune application bureau n'est disponible. Cependant, l'application mobile est gratuite sur Google Store et App Store.

## Base de données

```yml
mysql:
  restart: always
  image: mysql:${MATTERMOST_MYSQL_VERSION}
  environment:
    - MYSQL_USER=${MYSQL_USER}
    - MYSQL_PASSWORD=${MYSQL_PASSWORD}
    - MYSQL_DATABASE=${MYSQL_DATABASE}
    - MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
  volumes:
    - ${VOLUME_STORAGE_ROOT}/${MATTERMOST_DB_DATA_DIR}:/var/lib/mysql
  container_name: mysql-${MATTERMOST_SUBDOMAIN}-${DOMAIN}
```

**Image utilisée :** [MySQL](https://hub.docker.com/_/mysql/)

**Environnement :**

Les variables suivantes sont nécessaires à l'utilisation de la base :
* `MYSQL_USER` : nom de l'utilisateur associé à mattermost
* `MYSQL_PASSWORD` : mot de passe de l'utilisateur mattermost
* `MYSQL_DATABASE` : nom de la base associée à mattermost
* `MYSQL_ROOT_PASSWORD` : mot de passe de l'utilisateur root de la base

**Volumes :**

Le volume utilisé ici permet la récupération des données de la base.

**Variables :**

Ces variables permettent de configurer le fichier `docker-compose.yml` sans avoir à y mettre le nez directement. Elles sont à renseigner dans un fichier `.env` semblable au fichier `.env_default` fourni :
* `DOMAIN` : nom de domaine utilisé pour avoir accès au serveur (ex : `example.com`)
* `MATTERMOST_MYSQL_VERSION` : version de l'image docker de MySQL utilisée
* `MATTERMOST_SUBDOMAIN` : sous domaine utilisé par l'application (ex : `mattermost` pour `mattermost.example.com`)
* `MATTERMOST_DB_DATA_DIR` : dossier utilisé comme volume pour la base de donnée
* `MYSQL_PASSWORD` : mot de passe de l'utilisateur associé à mattermost
* `MYSQL_ROOT_PASSWORD` : mot de passe associé à l'utilisateur root de la base de données
* `MYSQL_DB_NAME` : nom de la base de donnée associée à Mattermost
* `MYSQL_USER` : nom de l'utilisateur associé à Mattermost
* `VOLUME_STORAGE_ROOT` : dossier utilisé pour centraliser tout les volumes utilisés par les conteneurs Docker de l'installation.

**NB :** *toutes les variables à renseignée définissant des dossiers doivent contenir un chemin relatif d'origine la valeur de la variable VOLUME_STORAGE_ROOT.*

## Instance Mattermost

```yml
mattermost:
  restart: always
  image: jasl8r/mattermost:${MATTERMOST_VERSION}
  links:
    - mysql:mysql
  ports:
    - "${MATTERMOST_WEB_PORT}:80"
  environment:
    - MATTERMOST_SECRET_KEY=d9wVPX3x7h9wWkVVcwwTJ4knhfLkr3Mzf4CNL3WgdTTpJvjqWK3VzTp7pHHhjcqs
    - MATTERMOST_LINK_SALT=NPgCWVg4sK4c9dgTjrPtCWjkzMvHFtqzNLvXTJdKt4gWtzLXzzvjJ4Kjqs3fFkRv
    - MATTERMOST_RESET_SALT=7frPRCsdxs3zKLhKKWFkt3ksprzWFTkw3vnhcHXMp3d4zjkKjkPVMXsFxWRzf3qn
    - MATTERMOST_INVITE_SALT=7frPRCsdxs3zKLhKKWFkt3ksprzWFTkw3vnhcHXMp3d4zjkKjkPVMXsFxWRzf3qn
    - VIRTUAL_HOST=${MATTERMOST_SUBDOMAIN}.${DOMAIN}
    - LETSENCRYPT_HOST=${MATTERMOST_SUBDOMAIN}.${DOMAIN}
    - LETSENCRYPT_EMAIL=${MATTERMOST_SUBDOMAIN}.${DOMAIN}
  volumes:
    - ${VOLUME_STORAGE_ROOT}/${MATTERMOST_DATA_DIR}:/opt/mattermost/data
  container_name: ${MATTERMOST_SUBDOMAIN}-${DOMAIN}
```

**Image utilisée :** [Mattermost par Jasl8r](https://store.docker.com/community/images/jasl8r/mattermost)

**Environnement :**

Ici, les variables d'environnement utilisées sont un peu spéciales :
* `MATTERMOST_SECRET_KEY` : sel des champs sensibles de la base de données.
* `MATTERMOST_LINK_SALT` : sel utilisé pour les liens publiques.
* `MATTERMOST_RESET_SALT` : sel utilisé pour signer les mails de remise à zéro des mots de passe.
* `MATTERMOST_INVITE_SALT` : sel utilisé pour signer les mails d'invitations.

**Volumes :**

Le volume utilisé permet de récupérer les données liées à l'application.

**Variables :**

Ces variables permettent de configurer le fichier `docker-compose.yml` sans avoir à y mettre le nez directement. Elles sont à renseigner dans un fichier `.env` semblable au fichier `.env_default` fourni :
* `DOMAIN` : nom de domaine utilisé pour avoir accès au serveur (ex : `example.com`)
* `MATTERMOST_VERSION` : version de l'image docker de Mattermost utilisée
* `MATTERMOST_SUBDOMAIN` : sous domaine utilisé par l'application (ex : `mattermost` pour `mattermost.example.com`)
* `MATTERMOST_DATA_DIR` : dossier utilisé comme volume pour les données de Mattermost
* `VOLUME_STORAGE_ROOT` : dossier utilisé pour centraliser tout les volumes utilisés par les conteneurs Docker de l'installation.

**NB :** *toutes les variables à renseignée définissant des dossiers doivent contenir un chemin relatif d'origine la valeur de la variable VOLUME_STORAGE_ROOT.*
