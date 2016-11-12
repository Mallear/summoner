# Erreurs rencontrées relatives à Docker

## Conteneur de base de données à cours d'espace d'écriture
**Problème :**

Il se peut qu'un conteneur d'une base de donnée quelconque (PostgreSQL, MySql, MariaDB ...) soit incapable de s'initialiser et ressorte une erreur du genre :
`could not write to file [...] no space left on device`
Cela est du au fait que le storage driver `device mapper` utilise le file système root. Ce filesystem se rempli au fur et à mesure des données utilisées par Docker : les images, les volumes montés ...

**Solution :**

Pour régler cela, il y a plusieurs solutions :
* Supprimer tout les volumes orphelins (ne possédant plus de container les utilisant). Pour les détecter, nous pouvons utiliser la commande `docker volume`.
  * `docker volume ls -qf dangling=true` : liste tout les volumes orphelins
  * `docker volume ls -qf dangling=true | xargs -r docker volume rm` : supprime tout les volumes orphelins
[Solutions & warnings](https://github.com/chadoe/docker-cleanup-volumes)

* Supprimer les images non utilisées
* Augmenter la limite disponible de ce filesystem.
