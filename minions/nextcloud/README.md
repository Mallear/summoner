# Container Nextcloud

_Documentation du fichier [`docker-compose.yml`](docker-compose.yml) d'un conteneur pour une instance Nextcloud._

Nextcloud est une solution de stockage en _Cloud_ opensource possédant une interface web, un client bureau et une application mobile gratuite.

## Base de données

```yml
nextcloud-db:
  image: mariadb:${NEXTCLOUD_MARIADB_VERSION}
  container_name: mariadb-${NEXTCLOUD_SUBDOMAIN}-${DOMAIN}
  volumes:
    - ${VOLUME_STORAGE_ROOT}/${NEXTCLOUD_DB_DATA_DIR}:/var/lib/mysql
  environment:
    - MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
    - MYSQL_DATABASE=${MYSQL_DB_NAME}
    - MYSQL_USER=${MYSQL_USER}
    - MYSQL_PASSWORD=${MYSQL_PASSWORD}
```

**Image utilisée :** [mariadb](https://hub.docker.com/_/mariadb/)

**Environnement :**

La base MariaDB nécessite la définition des variables suivantes :
* `MYSQL_ROOT_PASSWORD` : mot de passe de l'utilisateur root
* `MYSQL_DATABASE` : nom de la base de données associée à Nextcloud
* `MYSQL_USER` : utilisateur associé à Nextcloud
* `MYSQL_PASSWORD` : mot de passe de l'utilisateur

**Volumes :** Pour conserver les données de la base de données, un volume lié au dossier `var/lib/mysql` peut être créé.

**Variables :**

Ces variables permettent de configurer le fichier `docker-compose.yml` sans avoir à y mettre le nez directement. Elles sont à renseigner dans un fichier `.env` semblable au fichier `.env_default` fourni :
* `DOMAIN` : nom de domaine utilisé pour avoir accès au serveur (ex : `example.com`)
* `NEXTCLOUD_MARIADB_VERSION` : version de l'image docker de MariaDB utilisée
* `NEXTCLOUD_SUBDOMAIN` : sous domaine utilisé par l'application (ex : `nextcloud` pour `nextcloud.example.com`)
* `NEXTCLOUD_DB_DATA_DIR` : dossier utilisé comme volume pour la base de donnée
* `MYSQL_PASSWORD` : mot de passe de l'utilisateur associé à nextcloud
* `MYSQL_ROOT_PASSWORD` : mot de passe associé à l'utilisateur root de la base de données
* `MYSQL_DB_NAME` : nom de la base de donnée associée à Nextcloud
* `MYSQL_USER` : nom de l'utilisateur associé à Nextcloud
* `VOLUME_STORAGE_ROOT` : dossier utilisé pour centraliser tout les volumes utilisés par les conteneurs Docker de l'installation.

**NB :** *toutes les variables à renseignée définissant des dossiers doivent contenir un chemin relatif d'origine la valeur de la variable VOLUME_STORAGE_ROOT.*


## Instance Nextcloud

```yml
nextcloud:
  image: wonderfall/nextcloud:${NEXTCLOUD_VERSION}
  container_name: ${NEXTCLOUD_SUBDOMAIN}-${DOMAIN}
  links:
    - nextcloud-db:nextcloud-db
  environment:
    - UID=1000
    - GID=1000
    - UPLOAD_MAX_SIZE=10G
    - APC_SHM_SIZE=128M
    - OPCACHE_MEM_SIZE=128
    - REDIS_MAX_MEMORY=64mb
    - CRON_PERIOD=15m
    - TZ=Europe/Berlin
    - ADMIN_USER=${NEXTCLOUD_ADMIN_USER}
    - ADMIN_PASSWORD=${NEXTCLOUD_ADMIN_PASSWORD}
    - DB_TYPE=mysql
    - DB_NAME=${MYSQL_DB_NAME}
    - DB_USER=${MYSQL_USER}
    - DB_PASSWORD=${MYSQL_PASSWORD}
    - DB_HOST=nextcloud-db
    - VIRTUAL_HOST=${NEXTCLOUD_SUBDOMAIN}.${DOMAIN}
    - LETSENCRYPT_HOST=${NEXTCLOUD_SUBDOMAIN}.${DOMAIN}
    - LETSENCRYPT_EMAIL=contact@${NEXTCLOUD_SUBDOMAIN}.${DOMAIN}
  volumes:
    - ${VOLUME_STORAGE_ROOT}/${NEXTCLOUD_DATA_DIR}:/data
    - ${VOLUME_STORAGE_ROOT}/${NEXTCLOUD_CONFIG_DIR}:/config
    - ${VOLUME_STORAGE_ROOT}/${NEXTCLOUD_APPS_DIR}:/apps2
  ports:
    - "${NEXTCLOUD_WEB_PORT}:8888"
```

**Image utilisée :** [Nextcloud](https://hub.docker.com/r/wonderfall/nextcloud/)

**Environnement :**

Les variables d'environnement sont nombreuses :
* `UID` : nextcloud user id
* `GID` : nextcloud group id
* `UPLOAD_MAX_SIZE` : taille maximale d'upload de fichiers (défini les valeurs dans les fichiers `.htaccess` et `php.ini` (?))
* `APC_SHM_SIZE` : quantité de mémoire partagée allouée à APC (Alternative Php Cache).
* `OPCACHE_MEM_SIZE` : taille de la mémoire cache utilisée par OPCACHE.
* `REDIS_MAX_MEMORY` : taille maximale du buffer du serveur Redis
* `CRON_PERIOD` : période d'activation du cron unix.
* `TZ` : time zone définissant la langue et l'heure serveur.
* `ADMIN_USER` : utilisateur possédant les droits administrateurs
* `ADMIN_PASSWORD` : mot de passe du compte administrateur
* `DB_TYPE` : type de la base de données liée à l'instance
* `DB_NAME` : nom de la base de données
* `DB_USER` : utilisateur nextcloud de la base de données
* `DB_PASSWORD` : mot de passe de l'utilisateur nextcloud
* `DB_HOST` : adresse de la base de données. Correspond à l'adresse du serveur distant ou au nom du service docker.

**Volumes :**

La configuration de l'instance Nextcloud se trouve dans le dossier `/config`; les fichiers hébergés dans le dossier `/data` et les données relatives à l'application dans `/apps2`.

**Variables :**

Ces variables permettent de configurer le fichier `docker-compose.yml` sans avoir à y mettre le nez directement. Elles sont à renseigner dans un fichier `.env` semblable au fichier `.env_default` fourni :
* `DOMAIN` : nom de domaine utilisé pour avoir accès au serveur (ex : `example.com`)
* `NEXTCLOUD_VERSION` : version de l'image docker de Nextcloud utilisée
* `NEXTCLOUD_MARIADB_VERSION` : version de l'image docker de MariaDB utilisée
* `NEXTCLOUD_SUBDOMAIN` : sous domaine utilisé par l'application (ex : `nextcloud` pour `nextcloud.example.com`)
* `NEXTCLOUD_WEB_PORT` : port de l'hôte utilisé pour accéder à l'application
* `NEXTCLOUD_ADMIN_USER` : nom de l'utilisateur admin nextcloud
* `NEXTCLOUD_ADMIN_PASSWORD` : mot de passe de l'utilisateur admin
* `NEXTCLOUD_DB_DATA_DIR` : dossier utilisé comme volume pour la base de donnée
* `NEXTCLOUD_DATA_DIR` : dossier utilisé comme volume pour les données de Nextcloud
* `NEXTCLOUD_CONFIG_DIR` : dossier utilisé comme volume pour les fichiers de configuration de Nextcloud
* `NEXTCLOUD_APPS_DIR` : dossier utilisé comme volume pour les données liées à l'application Nextcloud
* `VOLUME_STORAGE_ROOT` : dossier utilisé pour centraliser tout les volumes utilisés par les conteneurs Docker de l'installation.

**NB :** *toutes les variables à renseignée définissant des dossiers doivent contenir un chemin relatif d'origine la valeur de la variable VOLUME_STORAGE_ROOT.*
