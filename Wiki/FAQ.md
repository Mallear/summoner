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


## Problème de transfert de fichier sur Nextcloud
**Problème :**

Lors de l'import de gros fichier (>2Mo) sur l'application Nextcloud, il se peut que l'erreur `request entity too large` apparaisse. Cela signifie que le fichier en cours de traitement est trop lourd pour être accepté par le serveur.

Cette restriction de taille de transfert peut être effectué par des fichiers de config directement dans la configuration  Nextcloud (.htaccess, php.ini) ou bien par Nginx.

**Solution :**

* Ajouter le fichier `nextcloud.domaine` dans le dossier vhost.d de Nginx et ajouter la ligne `client_max_body_size 2000m;`.
* Vérifier les tailles autorisées par le fichier `.htaccess` ou le fichier `php.ini`.
