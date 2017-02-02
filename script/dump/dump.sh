#!/bin/bash

DATABASE_TYPE=("mongodb" "mysql" "postgresql" "mariadb")
DATE=`date +%F_%H_%M_%S`

echo -e "[`date +%F_%H_%M_%S`] Starting database dump."

source ~/.summoner

# Get all the .env file for all the applications
ENV_FILES=`find $MINIONS_DIR -name .env`

for FILE in $ENV_FILES
do
  source $FILE
done

echo -e "\033[33m[`date +%F_%H_%M_%S`] Online container analyse ... \033[0m"
echo ""

# Get all running DB containers
for TYPE in ${DATABASE_TYPE[@]}
do
  DOCKER_LIST+=" `docker ps -f "name=$TYPE" --format "{{.Names}}"`"
done

echo -e "\033[33m[`date +%F_%H_%M_%S`] Containers found : \033[0m"

for CONTAINER in $DOCKER_LIST
do
  echo -e "- $CONTAINER"
done

echo ""


# WARNING : if no docker container online
if [ ${#DOCKER_LIST} -eq 0 ]; then
  echo -e "\033[31m[`date +%F_%H_%M_%S`] No container found ... \033[0m"
else # There is at least one container to save

  DROPBOX_DIR=/Summoner/Minions
  DUMP_DIR=$VOLUME_STORAGE_ROOT/backup

  for CONTAINER in $DOCKER_LIST
  do
    # Getting all parameters of the application
    IFS='-' read -r -a PARAMETERS <<< "$CONTAINER"
    TYPE=${PARAMETERS[0]}
    APPLICATION=${PARAMETERS[1]}
    DOMAIN=${PARAMETERS[2]}

    # Setting all dump directories and files
    APPLICATION_DUMP_DIR=$DUMP_DIR/$APPLICATION/dump
    DROPBOX_APPLICATION_DUMP_DIR=$DROPBOX_DIR/$APPLICATION/dump/

    # Create the dump directory
    mkdir -p $APPLICATION_DUMP_DIR

    echo -e "\033[33m[`date +%F_%H_%M_%S`] Start dump of $CONTAINER container \033[0m"

    case "$TYPE" in
      "mongodb")  # Managing MongoDB database
        APPLICATION_DB_DATA_DIR=$DATABASE_STORAGE_ROOT/$APPLICATION
        APPLICATION_DUMP_FILE=$APPLICATION_DUMP_DIR/$APPLICATION-$DATE-dump.tar

        # Beware of the data directory inside the container !
        # Often set in /data/db for mongo databases
        docker exec mongodb-$APPLICATION-$DOMAIN bash -c 'mongodump ; tar -cvf dump.tar /dump ; mv dump.tar /data/db'

        # Naming the dumpfile
        mv $APPLICATION_DB_DATA_DIR/dump.tar $APPLICATION_DUMP_FILE

        echo -e "\033[32m[`date +%F_%H_%M_%S`] $CONTAINER dump finished. \033[0m"
        ;;

      "mysql") # Managin MySQL database
        APPLICATION_DUMP_FILE=$APPLICATION_DUMP_DIR/$APPLICATION-$DATE-dump.sql

        # Dumping the database
        docker exec $CONTAINER bash -c 'mysqldump --user root --password=$MYSQL_ROOT_PASSWORD --all-databases --single-transaction' > $APPLICATION_DUMP_FILE

        echo -e "\033[32m[`date +%F_%H_%M_%S`] $CONTAINER dump finished. \033[0m"

        ;;
      "postgresql") # Managing PostreSQL database
        APPLICATION_DUMP_FILE=$APPLICATION_DUMP_DIR/$APPLICATION-$DATE-dump.tar

        # Dump
        docker exec $CONTAINER bash -c 'pg_dump --username=$DB_USER -Ft $DB_NAME' > $APPLICATION_DUMP_FILE

        echo -e "\033[32m[`date +%F_%H_%M_%S`] $CONTAINER dump finished. \033[0m"
        ;;
      "mariadb") # Managing MariaDB database
        APPLICATION_DUMP_FILE=$APPLICATION_DUMP_DIR/$APPLICATION-$DATE-dump.sql

        # Dump the database
        docker exec $CONTAINER sh -c 'exec mysqldump --all-databases -uroot -p"$MYSQL_ROOT_PASSWORD"' > $APPLICATION_DUMP_FILE

        echo -e "\033[32m[`date +%F_%H_%M_%S`] $CONTAINER dump finished. \033[0m"
        ;;
      *)
        echo -e "\033[32m[`date +%F_%H_%M_%S`] Wrong case - Jump to next container"
        ;;
    esac
    # Sent it to dropbox
    ./dropbox_uploader.sh upload $APPLICATION_DUMP_FILE $DROPBOX_APPLICATION_DUMP_DIR
    echo ""
  done
fi
