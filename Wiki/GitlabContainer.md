Gitlab container & Gitlab CI documentation
---


# Gitlab & Gitlab runners

La création d'un système d'intégration continue grâce à la solution _Gitlab_ nécessite l'existance de deux instances différentes :
* Une instance d'administration _Gitlab_ permettant la gestion des utilisateurs, la création et gestion de dépôts, donnant l'accès aux paramètres du serveur _Git_ à proprement parler.
* Une instance d'administration des ressources d'intégration continue : _Gitlab CI_. Cette instance ne possède pas d'interface utilisateur. Elle sert principalement à définir et créer des _runners_, des conteneurs pré-configurés prêt à exécuter les tâches d'intégration.
Les runners peuvent être de plusieurs types mais nous utiliserons un conteneur _Docker_.

#### Définition des conteneurs
**Gitlab**  
Le service Gitlab nécessite un serveur _Rédis_ et un base de donnée _MySQL_ ou _PostgreSQL_. J'ai choisis une base _PostgreSQL_ qui permet la gestion d'un plus gros pool de données.  
Ainsi, la définition du Docker associé à la solution Gitlab contient une instance Redis, une instance PostgreSQL et une instance Gitlab liée aux deux précédentes.
**Docker-compose non fonctionnel Pour cause de variable d'environnement non détectée**
```shell
docker run --name gitlab-postgresql -d \
    --env 'DB_NAME=gitlabhq_production' \
    --env 'DB_USER=gitlab' --env 'DB_PASS=password' \
    --env 'DB_EXTENSION=pg_trgm' \
    --volume /srv/docker/gitlab/postgresql:/var/lib/postgresql \
    sameersbn/postgresql:9.5-1
&&
docker run --name gitlab-redis -d \
        --volume /srv/docker/gitlab/redis:/var/lib/redis \
        sameersbn/redis:latest
&&
docker run --name gitlab -d \
            --link gitlab-postgresql:postgresql --link gitlab-redis:redisio \
            --publish 10022:22 --publish 10080:80 --publish 10443:443 \
            --env 'GITLAB_HOST=puzle.xyz' \
            --env 'GITLAB_PORT=10080' --env 'GITLAB_SSH_PORT=10022' \
            --env 'GITLAB_SECRETS_DB_KEY_BASE=d9wVPX3x7h9wWkVVcwwTJ4knhfLkr3Mzf4CNL3WgdTTpJvjqWK3VzTp7pHHhjcqs' \
            --env 'GITLAB_SECRETS_SECRET_KEY_BASE=NPgCWVg4sK4c9dgTjrPtCWjkzMvHFtqzNLvXTJdKt4gWtzLXzzvjJ4Kjqs3fFkRv' \
            --env 'GITLAB_SECRETS_OTP_KEY_BASE=7frPRCsdxs3zKLhKKWFkt3ksprzWFTkw3vnhcHXMp3d4zjkKjkPVMXsFxWRzf3qn' \
            --volume /srv/docker/gitlab/gitlab:/home/git/data \
            --env VIRTUAL_HOST=gitlab.localhost \
            --env LETSENCRYPT_HOST=gitlab.localhost \
            --env LETSENCRYPT_EMAIL=contact@localhost \
            sameersbn/gitlab:latest
```

**Docker-compose**
```yml
postgresql:
  restart: always
  image: sameersbn/postgresql:9.5-1
  container_name: gitlab-postgresql
  environment:
    - DB_NAME=gitlabhq_production
    - DB_USER=gitlab
    - DB_PASS=password
    - DB_EXTENSION=pg_trgm
  volume:
    - /srv/docker/gitlab/postgresql:/var/lib/postgresql

redis:
  restart: always
  image: sameersbn/redis:latest
  container_name: gitlab-redis
  volume:
    - /srv/docker/gitlab/redis:/var/lib/redis

gitlab:
  image: sameersbn/gitlab:8.12.4
  container_name: gitlab
  links:
    - gitlab-postgresql:postgresql
    - gitlab-redis:redisio
  ports:
    - 10022:22
    - 10080:80
    - 10443:443
  environment:
    - GITLAB_PORT=10080
    - GITLAB_SSH_PORT=10022
    - GITLAB_SECRETS_DB_KEY_BASE=JPrx3ngpbwmLknsLqRKdMWvwwb9MLvLfkCcCfWpxVbwfJMJcvkHRKgTt9HpfmdgX
    - GITLAB_SECRETS_SECRET_KEY_BASE=cdJXTPqnwcmtrqcHqhz7xqHmCkFngMgRgq7wVTspVXMgq7qKvVrn47HnmxTtX4zK
    - GITLAB_SECRETS_OTP_KEY_BASE=9hbKtnNLmxCKdxMwTLKdnd4wWzRCTjzMs7dnhpNHLCxdrhwHhj3fPVtJ7KfdFLtf
  environment:
    - VIRTUAL_HOST=gitlab.localhost
    - LETSENCRYPT_HOST=gitlab.localhost
    - LETSENCRYPT_EMAIL=contact@localhost
  volumes:
    -/srv/docker/gitlab/gitlab:/home/git/data
```


**Gitlab CI**  
Plus précisément `gitlab-runner` est l'image officielle utilisée dans notre architecture. Elle n'a pas besoin d'être interfacée à un quelconque container et n'expose aucun port. Sa définition ne nécessite qu'un volume.  
La nouveauté est la nécessité de lié la socket de Docker au système afin d'utiliser des dockers comme runner. **à approfondir - Docker compose to build**

```shell
docker run -d --name gitlab-runner --restart always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /srv/gitlab-runner/config:/etc/gitlab-runner \
  gitlab/gitlab-runner:latest
```


## Création d'un projet Gitlab
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
