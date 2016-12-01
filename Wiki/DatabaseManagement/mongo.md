# Base de donnée mongodb
_Liens :_
* [Backup & restore tools for mongoDB](https://docs.mongodb.com/manual/tutorial/backup-and-restore-tools/)
* [MongoDC backups](https://docs.mongodb.com/v3.2/core/backups/)

### L'utilitaire `mongodump`
L'utilitaire `mongodump` permet la sauvegarde binaire d'une base de donnée dans un fichier BSON. Il est très utile pour effectuer des backups de petits déploiements. Cependant, il nécessite le parcours des index des tables et peut donc ralentir l'utilisation de la base par les applications.

**Utilisation**

* `mongodump --out dump_dir/` permet de faire un dump binaire de la base dans le dossier `dump_dir`
* `mongorestore dump_dir/` permet la restauration de la base à partir du dossier `dump_dir`

**Docker**

Pour lancer un dump dans le container, il suffit de lancer :  
`docker exec some_mogodb bash -c 'mongodump --out /path/to/dump/dir'`

Néanmoins, pour récupérer le résultat, il est bon de compresser le dossier et de le mettre dans le volume partagé :  
`docker exec some_mogodb bash -c 'mongodump | tar -cvf /path/to/shared/volume/file.tar'`

### Le snapshot du filesystem
_Liens :_
* [Snapshot de filesytems](https://docs.mongodb.com/v3.2/tutorial/backup-with-filesystem-snapshots/)

La sauvegarde par snapshot consiste à prendre un snapshot à un instant t des fichiers de la base de données. Ceci n'est pas une opération spécifique à MongoDB mais à l'OS. Les mécaniques du process dépendent alors du systeme de stockage. Par exemple, sur Linux, il est possible d'utiliser LVM (Logical Volume Manager).

Pour avoir un snapshot convenable de la base MongoDB, il faut que la journalisation soit activée et que le journal des logs se trouvent dans le même volume logique que les autres fichiers de données. Sans cela, il n'est pas assuré que le snapshot soit consistent et valide.

**Utilisation**
* Création d'un snapshot : `lvcreate --size 100M --snapshot --name mdb-snap01 /dev/vg0/mongodb`
* Archivage du snapshot : `umount /dev/vg0/mdb-snap01; dd if=/dev/vg0/mdb-snap01 | gzip > mdb-snap01.gz`
* Restoration du snapshot :
```bash
lvcreate --size 1G --name mdb-new vg0
gzip -d -c mdb-snap01.gz | dd of=/dev/vg0/mdb-new
mount /dev/vg0/mdb-new /srv/mongodb
```
