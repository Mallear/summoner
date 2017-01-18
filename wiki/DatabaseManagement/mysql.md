# Base de données MySQL

_Liens :_
* [MySQLdump utilitaire](http://dev.mysql.com/doc/refman/5.7/en/mysqldump.html)
* [MySQL backup methods](http://dev.mysql.com/doc/refman/5.7/en/backup-methods.html)
* [MySQL backup strategy](http://dev.mysql.com/doc/refman/5.7/en/backup-strategy-example.html)

### L'utilitaire `mysqldump`

L'utilitaire `mysqldump` permet d'effectuer des backup logiques d'une base de données. Il permet la création d'un fichier contenant les requêtes permettant de recreer une base de donnée et la repeupler.

**Utilisation**

* `mysqldump db_name > dump.sql` permet l'export de la base de donnée.
* `mysql db_name < dump.sql` permet de restaurer la base de donnée.

Dans notre cas, nous utilisons la commande suivante :  
`mysqldump --user root --password=$MYSQL_ROOT_PASSWORD --all-databases --single-transaction > dump.sql` permettant la sauvegarde de toutes les bases (`--all-databases`) et permettant une sauvegarde consistante de bases contenant des tables InnoDB (`--single-transaction`).
<!--- `--master-data` permet la sauvegarde des logs incrémentaux dans la sortie standard de `mysqldump` et ainsi de sauvegarder les logs. --->

Lors de la restauration du dump, la commande à exécuter est la suivante :
`mysql --user root --password=$MYSQL_ROOT_PASSWORD < dump.sql`

**Docker**  
Si la base MySQL est utilisée dans un docker :  
`docker exec some_mysql bash -c 'mysqldump --user root --password=000 --all-databases --single-transaction' >/path/to/dump/dir/dump.sql`
