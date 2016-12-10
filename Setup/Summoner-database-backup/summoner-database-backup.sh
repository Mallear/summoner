#!/bin/bash

DATABASE_TYPE=("mongodb" "mysql" "postgresql" "mariadb")
DATE=`date +%F_%H_%M_%S`

source ~/.summoner

ENV_FILES=`find $MINIONS_DIR -name .env`

# Sourcing all the environment variables
for FILE in $ENV_FILES
do
  source $FILE
done

DROPBOX_DIR=/Summoner/Minions/
BACKUP_DIR=$VOLUME_STORAGE_ROOT/backup

echo -e "Analyse des conteneurs en ligne ..."
echo ""

# Getting back all the DB containers
for TYPE in ${DATABASE_TYPE[@]}
do
  DOCKER_LIST+=" `docker ps -f "name=$TYPE" --format "{{.Names}}"`"
done

echo -e "\033[33m DB trouvées : \033[0m"

for CONTAINER in $DOCKER_LIST
do
  echo -e "- $CONTAINER"
done
echo ""

if [ ${#DOCKER_LIST} -eq 0 ]; then
  echo -e "\033[31m Aucun container trouvé ... \033[0m"
else # There is at least one container to save
  for CONTAINER in $DOCKER_LIST
  do
    echo -e "\033[33m Traitement du container : $CONTAINER \033[0m"

    # Getting all parameters of the application
    IFS='-' read -r -a PARAMETERS <<< "$CONTAINER"
    TYPE=${PARAMETERS[0]}
    APPLICATION="${PARAMETERS[1]^}"
    DOMAIN=${PARAMETERS[2]}

    DROPBOX_APPLICATION_BACKUP_DIR=$DROPBOX_DIR/$APPLICATION/backup/

    APPLICATION_DB_DATA_DIR=$APPLICATION"_DB_DATA_DIR"
    APPLICATION_DB_DATA_DIR=`echo $APPLICATION_DB_DATA_DIR | tr '[a-z]' '[A-Z]'`
    eval APPLICATION_DB_DATA_DIR=\$$APPLICATION_DB_DATA_DIR

    APPLICATION_BACKUP_DIR=$BACKUP_DIR/$APPLICATION/backup
    APPLICATION_BACKUP_FILE=$APPLICATION_BACKUP_DIR/$APPLICATION-$TYPE-$DATE-dump.tar.gz

    mkdir -p $APPLICATION_BACKUP_DIR

    echo $VOLUME_STORAGE_ROOT/$APPLICATION_DB_DATA_DIR

    cd $MINIONS_DIR/$APPLICATION
    # Shutting down the current app's for DB hard backup
    docker-compose down
    # Hard backup
    tar cvf $APPLICATION_BACKUP_FILE $VOLUME_STORAGE_ROOT/$APPLICATION_DB_DATA_DIR
    # Launch the container
    docker-compose up -d
    cd -

    ./dropbox_uploader.sh upload $APPLICATION_BACKUP_FILE $DROPBOX_APPLICATION_BACKUP_DIR
  done
fi
