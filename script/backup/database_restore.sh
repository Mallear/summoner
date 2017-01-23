#!/bin/bash

function usage
{
  echo -e "Summoner backup restoration"
  echo -e "Maxime Sibellas - maxime.sibellas@gmail.com"
  echo -e "Usage : $0 PARAMETER APPLICATION_NAME"
  echo -e "\nParameters :"
  echo -e "-d : backup database of the application"
  echo -e "-app : application backup"
  echo -e "-all : backup both app & database"
  echo -e "\nFor more info and examples, please see the README file.\n\n"
  exit 1
}

echo -e "[`date +%F_%H_%M_%S`] Start restoring backup database."

source ~/.summoner

ENV_FILES=`find $MINIONS_DIR -name .env`

# Sourcing all the environment variables
for FILE in $ENV_FILES
do
  source $FILE
done

# Check for numbers of parameters
if [ "$#" -lt "1" ]; then
  usage
  exit 1
fi

APPLICATION_NAME=$2
APPLICATION_NAME=`echo $APPLICATION_NAME | tr '[A-Z]' '[a-z]'`

case "$1" in
  "-d")
    DATABASE_TYPE=("mongodb" "mysql" "postgresql" "mariadb")
    # Checking if the (DB) container is running
    for TYPE in ${DATABASE_TYPE[@]}
    do
      CONTAINER+=`docker ps -f "name=$TYPE" --format "{{.Names}}" | grep -i $APPLICATION_NAME`
    done
    echo $CONTAINER
    if [ ${#CONTAINER} -eq 0 ]; then
      echo -e "[`date +%F_%H_%M_%S`] $APPLICATION_NAME containers are not running. Please start the containers and try again..."
      exit 1
    fi

    # Getting the database type
    IFS='-' read -r -a PARAMETERS <<< "$CONTAINER"
    TYPE=${PARAMETERS[0]}

    # Getting the dump file
    DROPBOX_BACKUP_DIR=/Summoner/Minions/$APPLICATION_NAME/backup
    LOCAL_BACKUP_DIR=$VOLUME_STORAGE_ROOT/backup/$APPLICATION_NAME/backup

    IFS=' ' read -r -a DROPBOX_FILES <<< `./dropbox_uploader.sh list $DROPBOX_BACKUP_DIR`
    if [ "${DROPBOX_FILES[@]: -1}" = "FAILED" ] || [ "${DROPBOX_FILES[@]: -1}" = "DONE" ]; then
      echo -e "[`date +%F_%H_%M_%S`] There is no backup archive available for $APPLICATION_NAME"
      echo -e "[`date +%F_%H_%M_%S`] Please create a backup by running summoner-database-backup.sh before trying to restore a backup."
      exit 1
    fi

    LAST_BACKUP_FILE=${DROPBOX_FILES[@]: -1}

    APPLICATION_DB_DATA_DIR=$APPLICATION_NAME"_DB_DATA_DIR"
    APPLICATION_DB_DATA_DIR=`echo $APPLICATION_DB_DATA_DIR | tr '[a-z]' '[A-Z]'`
    eval APPLICATION_DB_DATA_DIR=$VOLUME_STORAGE_ROOT/\$$APPLICATION_DB_DATA_DIR

    APPLICATION_DB_DATA_DIR=$VOLUME_STORAGE_ROOT/$APPLICATION_NAME

    ./dropbox_uploader.sh download $DROPBOX_BACKUP_DIR/$LAST_BACKUP_FILE /$LAST_BACKUP_FILE

  ;;
  "-a")
  ;;
  "-all")
  ;;
  *)
  ;;
esac

echo cd $MINIONS_DIR/Summoner-${APPLICATION_NAME}
docker-compose down
tar xvf /$APPLICATION_DB_DATA_DIR/$LAST_BACKUP_FILE
docker-compose up
cd -

echo -e "End"
