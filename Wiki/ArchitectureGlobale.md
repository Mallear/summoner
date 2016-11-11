Documentation sur l'architecture globale de Summoner
---

# Architecture globale

Chaque module de Summoner possède son `docker-compose.yml` dans un dossier qui lui est propre. Chaque docker possède des paramètres propres à l'environnement dans lequel il est déployé. Pour gérer cela, docker compose utilise un fichier `.env` pour charger les variables nécessaires à la définition du conteneur.

Dans notre cas, les paramètres suivant sont passés en variables :
* `DOMAIN` : le nom de domaine utilisé
* `DOCKER_VERSION` : version du docker_compose utilisée. **Non utilisée pour le moment**
* `[TOOL]\_VERSION` : version de l'image utilisée
* `[TOOL]\_SUBDOMAIN` : le sous domaine souhaité pour accéder à l'outil déployé
* `[TOOL]\_WEB\_PORT` : port de la machine à associer au port de l'interface web du conteneur

Le fichier .env est unique et positionné à la racine du Setup pour faciliter la modification des variables. Pour que chaque `docker-compose.yml` ait accès à ce fichier, un lien symbolique est créé dans le dossier (`ln -s ../.env`).
