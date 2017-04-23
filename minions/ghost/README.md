# Ghost container documentation

_Documentation du fichier [`docker-compose.yml`](docker-compose.yml) d'un conteneur pour site Ghost_

Ghost est une plate-forme open source de blogging simple de prise en main. Elle comprend un éditeur markdown pour faciliter la rédaction d'article, l'intégration d'images aux articles ...

## Définition du conteneur

```yml
ghost:
  image: ghost:${GHOST_VERSION}
  container_name: ghost-${GHOST_SUBDOMAIN}-${DOMAIN}
  ports:
    - "${GHOST_WEB_PORT}:2368"
  environment:
    - VIRTUAL_HOST=${GHOST_SUBDOMAIN}.${DOMAIN}
    - LETSENCRYPT_HOST=${GHOST_SUBDOMAIN}.${DOMAIN}
    - LETSENCRYPT_EMAIL=${GHOST_SUBDOMAIN}@${DOMAIN}
  volumes:
    - ${VOLUME_STORAGE_ROOT}/${GHOST_SUBDOMAIN}/blog:/var/lib/ghost/
```

**Image utilisée :** [ghost](https://hub.docker.com/_/ghost/)

**Port exposé :**

Le port exposé par défaut est le 2368. Libre à vous de le lié à un autre port de votre machine .

**Environnement :**

Les variables d'environnement utilisées sont nécessaires à Nginx pour définir le sous domaine du blog.  Pour plus d'information, voir la [documentation sur Nginx](https://gitlab.com/puzle-project/Summoner-nginx/blob/master/README.md).

**Volume :**

Le volume utilisée permet le stockage du contenu.

**Variables :**

Ces variables permettent de configurer le fichier `docker-compose.yml` sans avoir à y mettre le nez directement. Elles sont à renseigner dans un fichier `.env` semblable au fichier `.env_default` fourni :
* `DOMAIN` : nom de domaine utilisé pour avoir accès au serveur (ex : `example.com`)
* `GHOST_VERSION` : version utilisée de l'image docker
* `GHOST_SUBDOMAIN` : sous domaine utilisé par l'application (ex : `ghost` pour `ghost.example.com`)
* `GHOST_WEB_PORT` : port de l'hôte utilisé pour accéder à l'application
* `VOLUME_STORAGE_ROOT` : dossier utilisé pour centraliser tout les volumes utilisés par les conteneurs Docker de l'installation.

**NB :** *toutes les variables à renseignée définissant des dossiers doivent contenir un chemin relatif d'origine la valeur de la variable VOLUME_STORAGE_ROOT.*
