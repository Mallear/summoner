# Container Nextcloud

_Documentation du fichier [`docker-compose.yml`](../blob/master/Setup/Nextcloud/docker-compose.yml) d'un conteneur pour une instance Nextcloud._

Nextcloud est une solution de stockage en _Cloud_ opensource possédant une interface web, un client bureau et une application mobile gratuite.

## Définiion du conteneur

### Base de données

```yml
nextcloud-db:
  image: mariadb:10
  container_name: mariadb-${NEXTCLOUD_SUBDOMAIN}-${DOMAIN}
  volumes:
    - ${VOLUME_STORAGE_ROOT}/docker/nextcloud/db:/var/lib/mysql
  environment:
    - MYSQL_ROOT_PASSWORD=jaimelesfrites
    - MYSQL_DATABASE=nextcloud
    - MYSQL_USER=nextcloud
    - MYSQL_PASSWORD=jaimelesfrites
```

**Image utilisée :** [mariadb](https://hub.docker.com/_/mariadb/)

**Environnement :**

La base MariaDB nécessite la définition des variables suivantes :
* `MYSQL_ROOT_PASSWORD` : mot de passe de l'utilisateur root
* `MYSQL_DATABASE` : nom de la base de données associée à Nextcloud
* `MYSQL_USER` : utilisateur associé à Nextcloud
* `MYSQL_PASSWORD` : mot de passe de l'utilisateur

**Volumes :** Pour conserver les données de la base de données, un volume lié au dossier `var/lib/mysql` peut être créé.

### Instance Nextcloud

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
    - ADMIN_USER=admin
    - ADMIN_PASSWORD=admin
    - DB_TYPE=mysql
    - DB_NAME=nextcloud
    - DB_USER=nextcloud
    - DB_PASSWORD=jaimelesfrites
    - DB_HOST=nextcloud-db
    - VIRTUAL_HOST=${NEXTCLOUD_SUBDOMAIN}.${DOMAIN}
    - LETSENCRYPT_HOST=${NEXTCLOUD_SUBDOMAIN}.${DOMAIN}
    - LETSENCRYPT_EMAIL=contact@${NEXTCLOUD_SUBDOMAIN}.${DOMAIN}
  volumes:
    - ${VOLUME_STORAGE_ROOT}/docker/nextcloud/data:/data
    - ${VOLUME_STORAGE_ROOT}/docker/nextcloud/config:/config
    - ${VOLUME_STORAGE_ROOT}/docker/nextcloud/apps:/apps2
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
