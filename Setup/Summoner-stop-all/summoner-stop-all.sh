#!/bin/bash

source ~/.summoner

cd $MINION_DIR

MINIONS=`ls`

for MINION in $MINIONS
do
  if [[ -d ""${MINION} ]]; then
    cd $MINION
    docker-compose down
    cd ..
  fi
done
