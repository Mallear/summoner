#!/bin/bash



function usage
{
  echo -e "Summoner dump restoration"
  echo -e "Maxime Sibellas - maxime.sibellas@gmail.com"
  echo -e "Usage : $0 [PARAMETERS] APPLICATION_NAME"
  echo -e "\nParameters :"
  echo -e "-f --file :    set the file to use for dump restoring"
  echo -e "\nFor more info and examples, please see the README file.\n\n"
  exit 1
}

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

DATABASE_TYPE=("mongodb" "mysql" "postgresql" "mariadb")
APPLICATION_NAME=$1
APPLICATION_NAME=`echo $APPLICATION_NAME | tr '[A-Z]' '[a-z]'`

# Checking if the (DB) container is running
for TYPE in ${DATABASE_TYPE[@]}
do
  CONTAINER+=`docker ps -f "name=$TYPE" --format "{{.Names}}" | grep -i $APPLICATION_NAME`
done
echo $CONTAINER
if [ ${#CONTAINER} -eq 0 ]; then
  echo -e "$APPLICATION_NAME containers are not running. Please start the containers and try again..."
  exit 1
fi

# Getting the database type
IFS='-' read -r -a PARAMETERS <<< "$CONTAINER"
TYPE=${PARAMETERS[0]}

# Getting the dump file
DROPBOX_DUMP_DIR=/Summoner/Minions/$APPLICATION_NAME/dump
LOCAL_DUMP_DIR=$VOLUME_STORAGE_ROOT/backup/$APPLICATION_NAME/dump

IFS=' ' read -r -a DROPBOX_FILES <<< `./dropbox_uploader.sh list $DROPBOX_DUMP_DIR`
if [ "${DROPBOX_FILES[@]: -1}" = "FAILED" ] || [ "${DROPBOX_FILES[@]: -1}" = "DONE" ]; then
  echo -e "There is no dump file available for $APPLICATION_NAME"
  echo -e "Please create a dump by running summoner-database-dump.sh before trying to restore a dump."
  exit 1
fi

LAST_DUMP_FILE=${DROPBOX_FILES[@]: -1}

APPLICATION_DB_DATA_DIR=$APPLICATION_NAME"_DB_DATA_DIR"
APPLICATION_DB_DATA_DIR=`echo $APPLICATION_DB_DATA_DIR | tr '[a-z]' '[A-Z]'`
eval APPLICATION_DB_DATA_DIR=$VOLUME_STORAGE_ROOT/\$$APPLICATION_DB_DATA_DIR


./dropbox_uploader.sh download $DROPBOX_DUMP_DIR/$LAST_DUMP_FILE $APPLICATION_DB_DATA_DIR/$LAST_DUMP_FILE

case "$TYPE" in
  "mysql")
    # Restore the dump
    docker exec $CONTAINER bash -c 'mysql --user root --password=$MYSQL_ROOT_PASSWORD < /var/lib/mysql/*dump.sql'
    # Delete the dump file
    docker exec $CONTAINER bash -c 'rm /var/lib/mysql/*dump.sql'
    ;;
  "mongodb")
    # Untar the dump directory
    docker exec $CONTAINER bash -c 'tar xvf /data/db/*dump.tar'
    # Restore the dump
    docker exec $CONTAINER bash -c 'mongorestore dump'
    # Delete dump file & directory
    docker exec $CONTAINEr bash -c 'rm /data/db/*dump.tar; rm -r dump'
  ;;
  "postgresql")
    # Restore the dump
    docker exec $CONTAINER bash -c 'pg_restore -c -d $DB_NAME --username=$DB_USER /var/lib/postgresql/*dump.tar'
    # Delete the dump file
    docker exec $CONTAINER bash -c 'rm /var/lib/postgresql/*dump.tar'
    ;;
  "mariadb")
    # Restore the dump
    docker exec $CONTAINER bash -c 'mysql --user root --password=$MYSQL_ROOT_PASSWORD < /var/lib/mysql/*dump.sql'
    # Delete the dump file
    docker exec $CONTAINER bash -c 'rm /var/lib/mysql/*dump.sql'
    ;;
  *)
    echo "Database type not handled. Please contact us."
  ;;
esac
