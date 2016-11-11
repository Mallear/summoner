Nginx & letsencrypt container documentation
---
[Tutorial d'installation](https://tech.acseo.co/sites-https-docker-nginx-lets-encrypt/)
[Fichier compose](../blob/master/Setup/Nginx/docker-compose.yml)

# Nginx
_NGINX is a free, open-source, high-performance HTTP server and reverse proxy, as well as an IMAP/POP3 proxy server. NGINX is known for its high performance, stability, rich feature set, simple configuration, and low resource consumption._ - [Official Nginx wiki site](https://www.nginx.com/resources/wiki/)

Lors de la création de notre environnement de travail, la question s'est posée de comment avoir accès à nos différents outils via le même nom de domaine. La réponse semblait évidente : les sous-domaines.

Pour cela, nous pouvions les gérer via l'interface de notre hébergeur et de notre DNS, cependant, l'idée est d'avoir une tool box se déployant automatiquement avec une configuration valide en ajoutant que le strict nécessaire (voir aucune) action humaine supplémentaire. De plus, l'instanciation d'un container docker attribu une adresse IP aléatoire au container et les ports attribués peuvent différé. Le but était de simplifier au maximum la redirection vers les outils contenus dans les conteneurs.

Nous avons donc décidés d'utiliser un premier conteneur Docker afin de l'utiliser comme _reverse proxy_ pour rediriger les appels sur les sous-domaines vers l'outil correspondant. Pour cela, Nginx semblait être le plus utilisé et le plus documenté.

## Déploiement de l'image Docker
L'image docker Nginx utilisée n'est pas l'officielle mais une image open sourcée buildée à partir de l'originale. Elle expose les ports 80 à but d'accès web (c'est par là que passeront chacune des requêtes HTTP effectuées sur le serveur (domaine et sous domaines)); et le port 443 pour le protocole HTTPS(§ suivant).

```yml
nginx-proxy:
    restart: always
    image: jwilder/nginx-proxy
    ports:
        - "80:80"
        - "443:443"
    container_name: nginx-proxy-${DOMAIN}
    volumes:
        - /srv/docker/nginx/certs:/etc/nginx/certs:ro
        - /docker/vhost.d:/etc/nginx/vhost.d
        - /usr/share/nginx/html
        - /var/run/docker.sock:/tmp/docker.sock:ro
```

Cette image nécessite différents volumes :
* `/usr/share/nginx/html` : le répertoire web de l'application
* `/var/run/docker.sock` : la socket docker permettant la détection de la création d'un conteneur et la génération du sous domaine.
* `/docker/vhost.d` : la liste des hosts dans le network docker
* `/srv/docker/nginx/certs` : la liste des certificats de validation de l'hôte

Une fois ce container en place, il suffit alors de rajouter la variable d'environnement `VIRTUAL_HOST` dans chacun des containers qui devront être accessibles par via un sous-domaine.

**Exemple**
```shell
docker run --name foo -e VIRTUAL_HOST=sousdomaine.domaine bar
```
On peut ainsi accéder au container bar via l'adresse `sousdomaine.domaine`. C'est plus joli que `domaine:port`.


## SSL, certificats et LetsEncrypt
#### SSL & certificats
Malgré la configuration du reverse proxy Nginx, nous nous sommes confrontés à un problème de taille : nos sous-domaines n'étaient pas atteignables via https. Or certains nécessite absoluement ce protocole (Gitlab, Mattermost ...). Pour cela, il fallait trouver une solution d'authentification des sites web. L'auto certification n'était pas assez sûre et la plus part des certifications étaient payantes, ainsi la solution étaient d'utiliser un deuxième container Docker : LetsEncrypt.

#### LetsEncrypt
_Let’s Encrypt is a free, automated, and open Certificate Authority_ - [LetsEncrypt official website](https://letsencrypt.org/)

LetsEncrypt est un organisme de certification gratuit et automatique. Exactement ce dont on avait besoin pour valider nos requêtes sécurisées à nos containers : la certification se faisant à la volée à chaque déclaration de sous-domaine au prêt d'Nginx, il n'y aurait aucun problème lors de la déclaration d'un nouveau container.

```yml
nginx-proxy-companion:
    image: jrcs/letsencrypt-nginx-proxy-companion
    container_name: letsencrypt
    volumes:
        - /srv/docker/nginx/certs:/etc/nginx/certs:rw
        - /var/run/docker.sock:/var/run/docker.sock
    volumes_from:
        - nginx-proxy
```

Cette image nécessite différents volumes :
* `/srv/docker/nginx/certs` : le même que pour Nginx, afin de permettre la communication des certificats
* `/var/run/docker.sock` : pour utiliser la socket Docker et automatiser la génération des certificats

Le container LetsEncrypt est intimement lié à Nginx : il nécessite l'accès aux mêmes volumes (pour y déposer les certificats, entre autre). Pour générer un certificat pour un certain sous-domaine, il suffit de définir les variables d'environnement suivantes :
* `LETSENCRYPT_HOST`
* `LETSENCRYPT_EMAIL`

**Exemple :**
```shell
docker run --name foo -e LETSENCRYPT_HOST=sousdomaine.domaine -e LETSENCRYPT_EMAIL=domaine@contact.fr bar
```

## Fonctionnement final
Ainsi, à chaque déclaration d'un nouveau container docker nécessitant une interface web, un sous-domaine est défini via les trois variables d'environnement définies dans le docker-compose de l'outil. La configuration Nginx est alors rechargée à l'intérieur du docker (`nginx -s reload`), un certificat est généré par LetsEncrypt et le container est accessible via son interface web.

**Exemple :**
```shell
docker run --name foo -e VIRTUAL_HOST=sousdomaine.domaine -e LETSENCRYPT_HOST=sousdomaine.domaine -e LETSENCRYPT_EMAIL=domaine@contact.fr bar
```

**Docker-compose final**
```yml
nginx-proxy:
    restart: always
    image: jwilder/nginx-proxy
    ports:
        - "80:80"
        - "443:443"
    container_name: nginx-proxy
    volumes:
        - /srv/docker/nginx/certs:/etc/nginx/certs:ro
        - /docker/vhost.d:/etc/nginx/vhost.d
        - /usr/share/nginx/html
        - /var/run/docker.sock:/tmp/docker.sock:ro

nginx-proxy-companion:
    image: jrcs/letsencrypt-nginx-proxy-companion
    container_name: letsencrypt
    volumes:
        - /srv/docker/nginx/certs:/etc/nginx/certs:rw
        - /var/run/docker.sock:/var/run/docker.sock
    volumes_from:
        - nginx-proxy
```
