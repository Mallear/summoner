# Ghost container documentation

_Documentation du fichier [`docker-compose.yml`](../blob/master/Setup/Ghost/docker-compose.yml) d'un conteneur pour site Ghost_

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
    - /cedric-cf/blog:/var/lib/ghost/content
```

**Image utilisée :** [ghost](https://hub.docker.com/_/ghost/)

**Port exposé :**

Le port exposé par défaut est le 2368. Libre à vous de le lié à un autre port de votre machine .

**Environnement :**

Les variables d'environnement utilisées sont nécessaires à Nginx pour définir le sous domaine du blog.  Pour plus d'information, voir la [documentation sur Nginx](../blob/master/Wiki/NginxContainer.md).

**Volume :**

Le volume utilisée permet le stockage du contenu.
