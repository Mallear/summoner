#!/bin/bash

DATABASE_TYPE=("mongodb" "mysql" "postgresql" "mariadb")
DATE=`date +%F_%H_%M_%S`

echo -e "\033[33m[`date +%F_%H_%M_%S`] Starting database backup.\033[0m"

source ~/.summoner

ENV_FILES=`find $MINIONS_DIR -name .env`

# Sourcing all the environment variables
for FILE in $ENV_FILES
do
  source $FILE
done

echo -e "\033[33m[`date +%F_%H_%M_%S`] Analyse online containers ...\033[0m"
echo ""

# Getting back all the DB containers running
for TYPE in ${DATABASE_TYPE[@]}
do
  DOCKER_LIST+=" `docker ps -f "name=$TYPE" --format "{{.Names}}"`"
done

echo -e "\033[33m [`date +%F_%H_%M_%S`] Found databases : \033[0m"

for CONTAINER in $DOCKER_LIST
do
  echo -e "- $CONTAINER"
done
echo ""

# Dumping containers
if [ ${#DOCKER_LIST} -eq 0 ]; then
  echo -e "\033[31m[`date +%F_%H_%M_%S`] No containers fond ... \033[0m"
  exit 1
else # There is at least one container to save
  DROPBOX_DIR=/Summoner/Minions/
  BACKUP_DIR=$VOLUME_STORAGE_ROOT/backup
  DATABASE_DIR=$DATABASE_STORAGE_ROOT

  for CONTAINER in $DOCKER_LIST
  do
    echo -e "\033[33m[`date +%F_%H_%M_%S`] Dumping : $CONTAINER \033[0m"

    # Getting all parameters of the application
    IFS='-' read -r -a PARAMETERS <<< "$CONTAINER"
    TYPE=${PARAMETERS[0]}
    APPLICATION="${PARAMETERS[1]}"

    DROPBOX_APPLICATION_BACKUP_DIR=$DROPBOX_DIR/$APPLICATION/backup/

    APPLICATION_DB_DATA_DIR=$APPLICATION"_DB_DATA_DIR"
    APPLICATION_DB_DATA_DIR=`echo $APPLICATION_DB_DATA_DIR | tr '[a-z]' '[A-Z]'`
    eval APPLICATION_DB_DATA_DIR=\$$APPLICATION_DB_DATA_DIR

    APPLICATION_BACKUP_DIR=$BACKUP_DIR/$APPLICATION/backup
    APPLICATION_BACKUP_FILE=$APPLICATION_BACKUP_DIR/$APPLICATION-$TYPE-$DATE-backup.tar.gz

    mkdir -p $APPLICATION_BACKUP_DIR

    echo $VOLUME_STORAGE_ROOT/$APPLICATION_DB_DATA_DIR

    cd $MINIONS_DIR/$APPLICATION
    # Shutting down the current app's for DB hard backup
    docker-compose stop
    # Hard backup
    tar cvf $APPLICATION_BACKUP_FILE $DATABASE_STORAGE_ROOT/$APPLICATION
    # Launch the container
    docker-compose start
    cd - >> /dev/null

    ./dropbox_uploader.sh upload $APPLICATION_BACKUP_FILE $DROPBOX_APPLICATION_BACKUP_DIR
    echo -e "\033[32m[`date +%F_%H_%M_%S`] $CONTAINER backup finished. \033[0m"
  done
fi

echo -e "\033[33m[`date +%F_%H_%M_%S`] Backup ended."
