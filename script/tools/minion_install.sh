#!/bin/bash

source ~/.summoner

if [ -z $1 ]; then
  exit 1
fi

$MINIONS_DIR/$1/install.sh
