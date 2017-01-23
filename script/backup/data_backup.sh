#!/bin/bash

echo -e "\033[33m[`date +%F_%H_%M_%S`] Starting data backup.\033[0m"

source ~/.summoner

# Getting all the apps running

echo -e "\033[33m[`date +%F_%H_%M_%S`] Analyse online containers ...\033[0m"
echo ""

DOCKER_LIST+=" `docker ps --format "{{.Names}}"`"

for CONTAINER in ${DOCKER_LIST[@]}; do
  echo $CONTAINER
  IFS='-' read -r -a TOOL <<< "$CONTAINER"
  if [ "${#TOOL[@]}" -eq "2" ]; then
    APPLICATIONS+=" ${TOOL[0]}"
  fi
done

echo -e "\033[33m[`date +%F_%H_%M_%S`] Applications to backup : "
for APP in $APPLICATIONS; do
  echo $APP
done

# Source every .env file for the applications

for APP in $APPLICATIONS; do
  source $MINIONS_DIR/$APP/.env
done

# Backup every application
BACKUP_DIR=$VOLUME_STORAGE_ROOT/backup
DATA_DIR=$VOLUME_STORAGE_ROOT
DROPBOX_BACKUP_DIR=/Summoner/Minions/

for APP in $APPLICATIONS; do
  APP_DIR=$MINIONS_DIR/$APP
  APP_BACKUP_DIR=$BACKUP_DIR/$APP/data
  APP_DATA_DIR=$DATA_DIR/$APP
  DATE=`date +%F_%H_%M_%S`
  BACKUP_ARCHIVE=$APP_BACKUP_DIR/$APP-$DATE.tar.gz
  DROPBOX_APPLICATION_BACKUP_DIR=$DROPBOX_BACKUP_DIR/$APP/backup/data

  echo -e "\033[33m[`date +%F_%H_%M_%S`] Start $APP traitment.\033[0m"

  echo -e "\033[33m[`date +%F_%H_%M_%S`] Stop containers.\033[0m"
  cd $APP_DIR
  #docker-compose stop

  echo -e "\033[33m[`date +%F_%H_%M_%S`] Backup started ...\033[0m"
  mkdir -p $APP_BACKUP_DIR
  tar cvf $BACKUP_ARCHIVE $APP_DATA_DIR

  echo -e "\033[33m[`date +%F_%H_%M_%S`] Backup ended.\033[0m"

  echo -e "\033[33m[`date +%F_%H_%M_%S`] Restart containers.\033[0m"
  #docker-compose start

  echo -e "\033[33m[`date +%F_%H_%M_%S`] Sending backup archive to dropbox.\033[0m"
  ./dropbox_uploader.sh upload $BACKUP_ARCHIVE $DROPBOX_APPLICATION_BACKUP_DIR

done
