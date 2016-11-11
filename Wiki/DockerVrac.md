Docker Command list
---

# Back to basics

**Docker user story**
```shell
$ docker service start
$ docker run <image>
$ docker service stop
```

**Utilities**
- Définition du fichier Dockerfile :
```
FROM <original image>
RUN <cmd to set up the image>
CMD <cmd runned by the image>
```

- Build de l'image
```shell
$ docker build -t <user>/<repository name>:<tag>
```

- Push de l'image sur Docker Hub
```shell
$ docker tag <img id> <username>/<image name>:latest
$ docker login
$ docker push <username>/<image name>
```

- Liste des images
```shell
$ docker images
```

- Suppression des images  
_-f permet de forcer la suppression_
```shell
$ docker rmi -f <image>
```

- Suppression d'un container
`-f` permet de forcer la suppression dans le cas où le container run toujours
```shell
docker rm <container>
```

- Recherche d'image existante
```shell
$ docker search <image>
```

- Affichage des sorties standards d'un container
```shell
docker <container id> logs
```

- Liste des processus tournant dans un container
```shell
docker top <container>
```

- Récupération des carac du container
```shell
docker inspect <container>
```

- Télécharger sans run le container
```shell
docker pull <image>
```

- Executer un terminal dans un container
```shell
docker exec -it <container> bash
```

- Lister tout les container
```
docker ps -a
```

- Supprimer tout les container
```shell
docker rm `docker ps -aq`
```

**Docker run**
```shell
docker run -t -i ubuntu /bin/bash
```
* `docker run` runs a container
* `ubuntu` is the image run
* `-t` flag : assign a terminal inside the new container
* `-i` flag : interactive connection by grabbind the STDIN of the container
* `/bin/bash` : launches a Bash shell
* `--name` : allow to give a name to a container

**`Docker run` - Other flags**
* -d : deamonize the container (run in the background)
* -c : add a command
* -p : map any required network ports inside our container to our host.  
Use :
```shell
docker run -p <machine port>:<container port>
```
*


**`Docker ps` - Flags**
* `-l` : informations about the last launched container


**`Docker logs` - Flags**
* `-f` : act like `tail -f`
*

### Docker network
* List all of the network
```shell
docker network ls
```

* Remove a container from the network
```shell
docker network disconnet <network> <container>
```

* Create a network
`-d` : tells docker to use driver for network type
```shell
docker network create -d <network type> <network name>
```



## La modification d'un container Docker & soumission
### À la main
En lançant un container avec un terminal interactif (`docker run -t -i <image`), il est possible d'installer tout les softs nécessaire au bon déroulement du container.

Il suffit alors de commiter les modifications sur un répot Docker Hub.
```shell
docker commit -m "comment" -a "Author" <id of the previous image> <target for the new image>
```

### Le Dockerfile

_TODO : list best practices_




# Docker Compose
 Tool for defining and running multi-container applications.
 - 3 Steps process :
  - Define the app's environment with a Dockerfile
  - Define the services that make up your app in a docker-compose.yml file. This allow them to run together in an isolated environment
  - Run `docker-compose up`

**Project name**  
  Defined by a project name to isolate each environment. IE : keep build to interfering with each other : a project name for a unique build number -> many build at a time. This is set by using the option -p or the COMPOSE_PROJECT_NAME environment variable.

# Automated build on Docker Hub

_Only GitHub & BitBukket complient_

# Docker & Docker Compose Update
**TODO**
