#!/bin/bash

source ~/.summoner

cd $SUMMONER_HOME

MINIONS=`ls -p $MINIONS_DIR`

for MINION in $MINIONS
do
  echo $MINION
  if [[ -d "${MINION}" ]]; then
    cd $MINION
    docker-compose pull
    docker-compose up -d
    cd ..
  fi
done
