# Erreurs rencontrées relatives à Docker

## Conteneur de base de données à cours d'espace d'écriture
**Problème :**

Il se peut qu'un conteneur d'une base de donnée quelconque (PostgreSQL, MySql, MariaDB ...) soit incapable de s'initialiser et ressorte une erreur du genre :
`could not write to file [...] no space left on device`
Cela est peut être du au fait qu'il ne peut plus réserver de volume car tout l'espace est déjà réservé (et non occupé).

Une des cause peut être la présence de plus de volumes alloués que de volumes utilisés. Ceci peut être du à de nombreux tests sans suppressions des volumes.

**Solution :**

Pour régler cela, il suffit de supprimer tout les volumes orphelins (ne possédant plus de container les utilisant). Pour les détecter, nous pouvons utiliser la commande `docker volume`.

* `docker volume ls -qf dangling=true` : liste tout les volumes orphelins
* `docker volume ls -qf dangling=true | xargs -r docker volume rm` : supprime tout les volumes orphelins

[Solutions & warnings](https://github.com/chadoe/docker-cleanup-volumes)
