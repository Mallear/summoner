#!/bin/bash

source ~/.summoner

if [ -z $1 ]; then
  exit 1
fi

sed -n 'H;${x;s/applications: .*/$1\
&/;p;}' $SUMMONER_HOME/config.yml


#$MINIONS_DIR/$1/install.sh
