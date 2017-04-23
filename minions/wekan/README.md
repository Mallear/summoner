# Conteneur Wekan
_Documentation du fichier [`docker-compose.yml`](docker-compose.yml) d'un conteneur pour une instance Wekan_

Wekan est un kanban opensource semblable à [Trello](https://trello.com).

## Base de données

```yml
mongo:
  restart: always
  image: mongo:${WEKAN_MONGODB_VERSION}
  container_name: mongodb-${WEKAN_SUBDOMAIN}-${DOMAIN}
  volumes:
    - ${VOLUME_STORAGE_ROOT}/${WEKAN_DB_DATA_DIR}:/data/db
```

**Image utilisée :** [MondoDB](https://hub.docker.com/_/mongo)

**Environnement :**

Aucune variable d'environnement n'est nécessaire pour l'utilisation de ce conteneur.

**Volume :**

Le volume est associé au dossier `/data/db` du conteneur et permet de sauvegarder les données de la base.

**Variables :**

Ces variables permettent de configurer le fichier `docker-compose.yml` sans avoir à y mettre le nez directement. Elles sont à renseigner dans un fichier `.env` semblable au fichier `.env_default` fourni :
* `DOMAIN` : nom de domaine utilisé pour avoir accès au serveur (ex : `example.com`)
* `WEKAN_MONGODB_VERSION` : version de l'image docker de MongoDB utilisée
* `WEKAN_SUBDOMAIN` : sous domaine utilisé par l'application (ex : `wekan` pour `wekan.example.com`)
* `WEKAN_DB_DATA_DIR` : dossier utilisé comme volume pour la base de donnée
* `VOLUME_STORAGE_ROOT` : dossier utilisé pour centraliser tout les volumes utilisés par les conteneurs Docker de l'installation.

**NB :** *toutes les variables à renseignée définissant des dossiers doivent contenir un chemin relatif d'origine la valeur de la variable VOLUME_STORAGE_ROOT.*


## Instance Wekan

```yml
wekan:
  image: mquandalle/wekan:${WEKAN_VERSION}
  container_name: ${WEKAN_SUBDOMAIN}-${DOMAIN}
  links:
    - mongo:db
  environment:
    - VIRTUAL_HOST=${WEKAN_SUBDOMAIN}.${DOMAIN}
    - LETSENCRYPT_HOST=${WEKAN_SUBDOMAIN}.${DOMAIN}
    - LETSENCRYPT_EMAIL=${WEKAN_SUBDOMAIN}@${DOMAIN}
    - "MONGO_URL=mongodb://db"
    - "ROOT_URL=http://${WEKAN_SUBDOMAIN}.${DOMAIN}"
    - MAIL_URL=puzle.project@gmail.com
  ports:
    - ${WEKAN_WEB_PORT}:80
```

**Image utilisée :** [mquandalle/wekan](https://hub.docker.com/r/mquandalle/wekan/)

**Environnement :**

Les variables suivantes sont nécessaires à la configuration de Wekan :
* `MONGO_URL` : contient l'URL de la base MongoDB
* `ROOT_URL` : URL vers la plate-forme Wekan. Si elle est mal configurée, il se peut que des actions soient impossible à cause d'une mauvaise redirection (selection des cartes ...)
* `MAIL_URL` : addresse mail avec laquelle envoyer les notifications

**Volumes :**

Aucun volume n'est nécessaire au conteneur.

**Variables :**

Ces variables permettent de configurer le fichier `docker-compose.yml` sans avoir à y mettre le nez directement. Elles sont à renseigner dans un fichier `.env` semblable au fichier `.env_default` fourni :
* `DOMAIN` : nom de domaine utilisé pour avoir accès au serveur (ex : `example.com`)
* `WEKAN_SUBDOMAIN` : sous domaine utilisé par l'application (ex : `wekan` pour `wekan.example.com`)
* `WEKAN_VERSION` : version de l'image docker de MySQL utilisée
* `WEKAN_WEB_PORT` : port accessible par http
* `VOLUME_STORAGE_ROOT` : dossier utilisé pour centraliser tout les volumes utilisés par les conteneurs Docker de l'installation.

**NB :** *toutes les variables à renseignée définissant des dossiers doivent contenir un chemin relatif d'origine la valeur de la variable VOLUME_STORAGE_ROOT.*
