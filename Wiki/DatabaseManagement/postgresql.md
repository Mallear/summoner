# Postgres

_Liens :_
* [Doc postgres backup SQL](http://docs.postgresql.fr/8.1/backup.html)
* [Doc postgres restore SQL](http://docs.postgresql.fr/8.1/app-pgrestore.html)
* [Doc sur l'outils `pg_dump`](http://docs.postgresql.fr/8.1/app-pgdump.html)
* [Doc postgres backup système](http://docs.postgresql.fr/8.1/backup-file.html)
* [Doc postgres backup à chaud](http://docs.postgresql.fr/8.1/backup-online.html)
* [Bonus : doc sur la migration](http://docs.postgresql.fr/8.1/migration.html)
* [**Pour aller plus loin** : pg_basebackup pour les backup de cluster](https://www.postgresql.org/docs/9.4/static/app-pgbasebackup.html)


### Dump
Tout comme pour MariaDB, un utilitaire peut être utilisé : `pg_dump`. Il permet la sauvegarde rapide et simple de bases de données.

**Utilisation**

* `pg_dump dbname > backupfile.out` [1]
* `pg_dump -Ft dbname > backupfile.tar` [2]

Options :
* `-Ft` permet la compression en fichier .tar

La sortie standard de `pg_dump` se fait dans la sortie standard, une redirection de flux est nécessaire.

_Exemple d'utilisation :_
Pour la sauvegarde de la base postgresql utilisée avec la plate forme Gitlab :
`pg_dump --username=gitlab -Ft gitlabhq_production > backup.tar`

**Docker**

Dans le cas d'utilisation de la base dans un conteneur Docker (**/!\ chose à ne jamais faire dans un environnement de prod**), la commande peut être exécutée de l'extérieur du conteneur de cette manière :  
`docker exec some_postgres bash -c 'pg_dump --username=gitlab -Ft gitlabhq_production' > backup.tar`

### Restauration SQL
Plusieurs solutions sont possibles selon le backup effectué :

* [1] : `psql -d dbname -f backupfile.out`
* [2] : `pg_restore -C newDbName backupfile.tar`  
`pg_restore -C` créer une nouvelle base, se connecte à cette base et la peuple des données du fichier de backup.

---

### Backup fichier / Backup à froid

Cette stratégie consiste en la sauvegarde des fichiers utilisés par PostgreSQL pour enregistrer les données. Pour cela, il suffit d'utiliser GNU tar pour compresser les fichiers du dossier contenant les données de la base (dans notre cas `/var/lib/postgresql`).

Cependant, il y a deux restrictions à cette méthode :
* Le serveur doit être arrêté pour obtenir une sauvegarde utilisable. Il en va de même pour la restauration.
* La sauvegarde et la restauration doivent être totales.

**Docker**

Si la base de donnée tourne dans un container Docker ayant un volume lié sur l'host, il suffit de stopper le container, d'archiver les fichiers du volume et de rallumer le container.

### Restauration d'un backup à froid

**Docker**

Arrêtez le container, remplacer les fichiers du volume par ceux de la sauvegarde, rallumez le container.

---

### Backup à chaud

Tout d'abord assurez-vous que l'archivage WAL est activé et fonctionnel.

Le backup à chaud nécessite de locker les données pour éviter leur modifitcation le temps de la sauvegarde. Pour cela, il faut prévenir le serveur de l'exécution de la sauvegarde grâce à commande SQL : `SELECT pg_start_backup('label');` où label est toute chaîne de caractère utilisée pour identifier de façon unique l'opération de sauvegarde. Cette commande crée un fichier `backup_label` contenant des informations sur la sauvegarde.

À partir de là, il est possible d'utiliser `tar` ou `cpio` afin de sauvegarder les fichiers.

Une fois la sauvegarde fini, prévenez le serveur avec la commande `SELECT pg_stop_backup();`.

Une fois que les fichiers des segments WAL utilisés lors de la sauvegarde sont archivés de la même façon qu'une partie de l'activité normale de sauvegarde de la base de données, vous avez terminé.

### Restauration d'une sauvegarde à chaud

Arrêtez le postmaster s'il est en cours d'exécution.

Si vous avez de la place pour le faire, copiez le répertoire entier des données du groupe et tout tablespace dans un emplacement temporaire au cas où vous en auriez besoin plus tard. Notez que cette précaution demandera que vous ayez assez de place libre sur votre système pour contenir deux copies de votre base de données existante. Si vous n'avez pas assez de place, vous devez au moins copier le contenu du sous-répertoire pg_xlog du répertoire des données car il pourrait contenir des journaux qui n'ont pas été archivés avant l'arrêt du serveur.

Effacez tous les fichier et sous-répertoires existants sous le répertoire des données du groupe et sous les répertoires racines des tablespaces que vous utilisez.

Restaurez les fichiers de la base de données à partir de votre sauvegarde. Faites attention à ce qu'ils soient restaurés avec le bon propriétaire (l'utilisateur système de la base de données, et non pas root !) et avec les bons droits. Si vous utilisez les espaces logiques, vous vérifirez que les liens symboliques dans pg_tblspc/ ont été correctement restaurés.

Supprimez tout fichier présent dans pg_xlog/ ; ils proviennent de la sauvegarde et sont du coup probablement obsolètes. Si vous n'avez pas archivé pg_xlog/ du tout, alors re-créez ce répertoire ainsi que le sous-répertoire pg_xlog/archive_status/.

Si vous aviez des fichiers segments WAL non archivés que vous avez sauvegardé dans l'étape 2, copiez-les dans pg_xlog/ (il est mieux de les copier, pas de les déplacer, car vous aurez toujours les fichiers non modifiés si un problème survient et que vous devez recommencer).

Créez un fichier de commandes de récupération recovery.conf dans le répertoire des données du groupe (voir Configuration de la récupération). De plus, vous pourriez vouloir modifier temporairement pg_hba.conf pour empêcher les utilisateurs ordinaires de se connecter tant que vous n'êtes pas certain que la récupération a réussi.

Lancez le postmaster. Le postmaster se trouvera en mode récupération et commencera la lecture des fichiers WAL archivés dont il a besoin. À la fin du processus de récupération, le postmaster renommera recovery.conf en recovery.done (pour empêcher de retourner accidentellement en mode de récupération dans le cas d'un arrêt brutal un peu plus tard), puis commencera les opérations normales de la base de données.

Inspectez le contenu de la base de données pour vous assurer que vous avez récupéré ce que vous vouliez. Sinon, retournez à l'étape 1. Si tout va bien, laissez vos utilisateurs venir en restaurant le fichier pg_hba.conf à son état normal.
