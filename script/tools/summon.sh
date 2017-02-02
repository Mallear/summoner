#!/bin/bash

add_application() {
  # tested with bash 4
  if [ $# -ne 4 ];then
      echo "Fail adding application to config.yml"
      echo "Usage: $0 env prop value file"
      exit 1
  fi
  env=$1
  prop=$2
  text=$3
  file=$4
  while read -r line
  do
      case "$line" in
          "$env"* )
          toggle=1
          ;;
      esac
      if [ "$toggle" = 1 ];then
          if [[ $line =~ "$prop" ]] ;then
              line="${line%%\*} $text"
              toggle=0
          fi
      fi
      echo "$line"
  done < $file > t
  mv t $file
}


source ~/.summoner

if [ ! -f "$1" ]; then
  exit 1
fi

## Git clone sources & configure their environment
echo -e "\033[33m[`date +%F_%H_%M_%S`] Getting all sources from Git \033[0m"
echo -e "\033[33m[`date +%F_%H_%M_%S`] Cloning $1 sources \033[0m"
git clone git@gitlab.com:puzle-project/Summoner-$1.git $MINIONS_DIR/$1
echo -e "\033[33m[`date +%F_%H_%M_%S`] Deploying $1 ... \033[0m"
$MINIONS_DIR/$1/install.sh $SUMMONER_CONFIG_FILE
#echo -e "\033[33m[`date +%F_%H_%M_%S`] Add to the summoner context file \033[0m"
#add_application summoner applications $1 $SUMMONER_CONFIG_FILE
