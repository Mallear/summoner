# Gitlab container & Gitlab CI documentation

_Documentation du fichier [`docker-compose.yml`](Gitlab docker compose) de la solution Gitlab & GitlabCI_
---

La création d'un système d'intégration continue grâce à la solution _Gitlab_ nécessite l'existance de deux instances différentes :
* Une instance d'administration _Gitlab_ permettant la gestion des utilisateurs, la création et gestion de dépôts, donnant l'accès aux paramètres du serveur _Git_ à proprement parler.
* Une instance d'administration des ressources d'intégration continue : _Gitlab CI_. Cette instance ne possède pas d'interface utilisateur. Elle sert principalement à définir et créer des _runners_, des conteneurs pré-configurés prêt à exécuter les tâches d'intégration.
Les runners peuvent être de plusieurs types mais nous utiliserons un conteneur _Docker_.


## Définition des conteneurs
**Gitlab**  
Le service Gitlab nécessite un serveur _Redis_ et un base de donnée _MySQL_ ou _PostgreSQL_.

**Gitlab CI**  
Plus précisément `gitlab-runner` est l'image officielle utilisée dans notre architecture. Elle n'a pas besoin d'être interfacée à un quelconque container et n'expose aucun port. Sa définition ne nécessite qu'un volume.  
La nouveauté est la nécessité de lié la socket de Docker au système afin d'utiliser des dockers comme runner. **à approfondir**

### Base de données
```yml
postgresql:
  restart: always
  image: sameersbn/postgresql:${GITLAB_POSTGRE_VERSION}
  container_name: postgresql-${GITLAB_SUBDOMAIN}-${DOMAIN}
  environment:
    - DB_NAME=gitlabhq_production
    - DB_USER=gitlab
    - DB_PASS=password
    - DB_EXTENSION=pg_trgm
  volumes:
    - /srv/docker/gitlab/postgresql:/var/lib/postgresql
```

**Image utilisée :** [sameersbn/postgresql](https://hub.docker.com/r/sameersbn/postgresql/)

**Environnement :**  

La base PostgreSQL nécessite la définition des paramètres suivants :
* `DB_NAME` : nom de la base de donnée utilisée
* `DB_USER` : l'utilisateur utilisé par Gitlab
* `DB_PASS` : le mot de passe de l'utilisateur
* `DB_EXTENSION` : liste des extensions PostgreSQL à activer sur la base ([Postgre packages](https://www.postgresql.org/docs/9.4/static/contrib.html))

**Volumes :** Cette image nécessite un volume de stockage lié à son dossier `/var/lib/postgresql`.

### Serveur Redis
```yml
redis:
  restart: always
  image: sameersbn/redis:${GITLAB_REDIS_VERSION}
  container_name: redis-${GITLAB_SUBDOMAIN}-${DOMAIN}
  volumes:
    - /srv/docker/gitlab/redis:/var/lib/redis
```

**Image utilisée :** [sameersbn/redis](https://hub.docker.com/r/sameersbn/redis/)

**Environnement :**

Ce conteneur ne nécessite pas de variable d'environnement puisqu'on utilise le processus de `link` de docker pour le lié à notre instance Gitlab.

**Volumes :** Cette image nécessite un volume de stockage lié à son dossier `/var/lib/redis`.

### Serveur Gitlab
```yml
gitlab:
  image: sameersbn/gitlab:${GITLAB_VERSION}
  container_name: ${GITLAB_SUBDOMAIN}-${DOMAIN}
  links:
    - postgresql:postgresql
    - redis:redisio
  ports:
    - "${GITLAB_SSH_PORT}:22"
    - "${GITLAB_WEB_PORT}:80"
    - "${GITLAB_HTTPS_PORT}:443"
  environment:
    - GITLAB_PORT=${GITLAB_WEB_PORT}
    - GITLAB_SSH_PORT=${GITLAB_SSH_PORT}
    - GITLAB_SECRETS_SECRET_KEY_BASE=cdJXTPqnwcmtrqcHqhz7xqHmCkFngMgRgq7wVTspVXMgq7qKvVrn47HnmxTtX4zK
    - GITLAB_SECRETS_DB_KEY_BASE=JPrx3ngpbwmLknsLqRKdMWvwwb9MLvLfkCcCfWpxVbwfJMJcvkHRKgTt9HpfmdgX
    - GITLAB_SECRETS_OTP_KEY_BASE=9hbKtnNLmxCKdxMwTLKdnd4wWzRCTjzMs7dnhpNHLCxdrhwHhj3fPVtJ7KfdFLtf
    - VIRTUAL_HOST=${GITLAB_SUBDOMAIN}.${DOMAIN}
    - LETSENCRYPT_HOST=${GITLAB_SUBDOMAIN}.${DOMAIN}
    - LETSENCRYPT_EMAIL=contact@${DOMAIN}
  volumes:
    - /srv/docker/gitlab/gitlab:/home/git/data
```

**Image utilisée :** [sameersbn/gitlab](https://hub.docker.com/r/sameersbn/gitlab/)

**Environnement :**  
L'instance Gitlab peut être fortement paramètrable de part sa longue liste de variable d'environnement ([voir la liste](https://github.com/sameersbn/docker-gitlab#available-configuration-parameters)). Voici ceux utilisés ici :
* `GITLAB_SECRETS_SECRET_KEY_BASE` : chaîne de 64 caractères minimum utilisée pour le cryptage des sessions  
* `GITLAB_SECRETS_OTP_KEY_BASE` : chaîne de 64 charactères minimum utilisée pour les opérations liées au processus d'OPT (_One time password_).
* `GITLAB_SECRETS_DB_KEY_BASE` : chaîne de 32 charactères minimum utilisée pour le cryptage lié à la base de données.
* `GITLAB_PORT` : numéro du port lié au port 80 de l'instance
* `GITLAB_SSH_PORT` : numéro du port lié au port 22 de l'instance

**Volumes :**  
Cette image nécessite un volume de stockage lié à son dossier `/home/git/data`.

### Serveur de CI
```yml
gitlab-runner:
  image: gitlab/gitlab-runner:${GITLAB_CI_VERSION}
  container_name: CI-${GITLAB_SUBDOMAIN}-${DOMAIN}
  volumes:
    - /var/run/docker.sock:/var/run/docker.sock
    - /srv/gitlab-runner/config:/etc/gitlab-runner
```

**Image utilisée :** [gitlab/gitlab-runner](https://hub.docker.com/r/gitlab/gitlab-runner/)

**Volumes :**
Afin de pouvoir utiliser des images Docker en tant que runner, cette image doit posséder un lien entre la socket Docker de l'hébergeur et celle du conteneur. Ensuite, la config de l'instance est chargée dans le répertoire `/etc/gitlab-runner`.

# Création d'un projet Gitlab
La création d'un projet se fait simplement via l'interface web de l'instance _Gitlab_. Si le projet contient des tests unitaires, fonctionnels ou tout simplement s'il on veut tester la compilation du projet, il est possible d'ajouter un _runner_ à ce projet. Pour cela, il faut se rendre dans l'onglet de paramètre et sélectionner "_CI/CD pipelines_". A partir de cette interface, il est possible d'associer un runner au projet.

## Création d'un runner
La création d'un runner est simple : il suffit d'exécuter la commande suivante à l'intérieur du _Docker_ :
```shell
gitlab-runner register
# Ou bien, si l'on se trouve à l'extérieur de l'instance
docker exec -it gitlab-runner gitlab-runner register
```
Des questions de personnalisation seront posées :
* L'URL du coordinateur Gitlab, i.e. l'instance administrative de Gitlab. Ex : `https://gitlab.puzle.xyz`
**Ne pas oublier la partie : `https`**
* Le token de l'instance Gitlab : il peut être récupéré dans la partie _runners_ de l'instance administrative.
* Une courte description du runner.
* L'executeur du runner (**À approfondir**). Nous choisirons `docker-ssh` afin de pouvoir utiliser les containers Docker comme runners.
* L'image Docker utilisée par le runner. **À approfondir**

Après cela, le runner est créé et disponible dans la liste des runners de l'instance Gitlab. Si des projets étaient en attente d'un runner, il sera déjà associé à ceux-ci.

## Configuration du CI

Le conteneur est prêt à être utilisé. Il suffit maintenant de lui décrire les actions à réaliser à chaque `commit` reçu. Pour cela, rien de plus simple. Il suffit d'ajouter un fichier `.gitlab-ci.yml` à la racine du projet !

Biensur, un simple fichier vide ne suffit pas. Dans ce fichier, nous définirons des jobs décrivant chacun une action précise du script de CI. Ces jobs auront des dépendances, seront effectués ou non dans certains cas etc.


**Exemple de fichier :**
```yml
image: ruby:2.1
services:
  - postgres

before_script:
  - bundle install

after_script:
  - rm secrets

stages:
  - build
  - test
  - deploy

job1:
  stage: build
  script:
    - execute-script-for-job1
  only:
    - master
  tags:
    - docker
```
**TODO: Réussir à faire un .yml fonctionnel et l'expliciter**


[gitlab docker compose]:../blob/master/Setup/Gitlab&CI/docker-compose.yml
