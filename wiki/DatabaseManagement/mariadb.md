# MariaDB
_Liens :_
* [Doc `mysqldump`](https://mariadb.com/kb/en/mariadb/mysqldump/)
* [Doc backup et restauration](https://mariadb.com/kb/en/mariadb/backup-and-restore-overview/)

### Effectuer un dump sur une base MariaDB

L'utilitaire `mysqldump` utilisé pour faire des sauvegardes d'une base de donnée MariaDB. Il permet de d'exporter les paramètres d'une base dans un fichier de sauvegarde d'extension SQL, XML ou même CSV.

**Performance**

`mysqldump` est un processus mono thread, ce qui permet d'éviter la surcharge serveur et le ralentissement des applications qui tournent pendant la sauvegarde. Cependant, il a provoque des entrées/sorties non nécessaires.

Il est recommandé d'effectuer le dump de la base au sein du même réseau pour limiter la création d'entrée/sortie. Cependant, pour garder la bande passante pour les applications, il faut l'effectuer sur une seconde carte réseau.

**Utilisation**

* `mysqldump [options] db_name [table1_name ...]` sauvegarde le/les table/s de la base sélectionnée.
* `mysqldump [options] --database db_name ...` sauvegarde la/les bases de données
* `mysqldump [options] --all-databases` sauvegarde toutes les bases de données

Options utiles :
* `--user=[user_name]`
* `--password=[user_password]`

La sortie de `mysqldump` se fait dans la sortie standard. Il faut donc rediriger le flux dans un fichier choisi (`backup_file.sql` par exemple).

_Exemple d'utilisation :_
Pour la sauvegarde de la base MariaDB utilisée avec l'application Nextcloud :
`mysqldump --user=root --password=${MYSQL_ROOT_PASSWORD} ${MYSQL_DATABASE} > /some/path/to/you/file/backup_nextcloud.sql`

_Notes :_ Si les tables de la base sont des tables MylSAM (MySQL 3.23 à MySQL 5.5), il est préférable d'utiliser l'utilitaire `mysqlhotcopy`.

**Docker**

Dans le cas d'utilisation de la base dans un conteneur Docker (**/!\ chose à ne jamais faire dans un environnement de prod**), la commande peut être exécutée de l'extérieur du conteneur de cette manière :  
`docker exec some-mariadb sh -c 'exec mysqldump --all-databases -uroot -p"$MYSQL_ROOT_PASSWORD"' > /some/path/on/your/host/all-databases.sql`

### Effectuer un backup sur une base MariaDB
