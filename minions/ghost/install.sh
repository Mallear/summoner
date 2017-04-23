#!/bin/bash

parse_yaml() {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}
source ~/.summoner
summoner_config_file=$1

GHOST_DIR=$MINIONS_DIR/ghost

echo -e "\033[33m[`date +%F_%H_%M_%S`] Starting Ghost installation.\033[0m"
if [ ! -e "$MINIONS_DIR/ghost/config.yml" ]; then
  echo -e "\033[31m[`date +%F_%H_%M_%S`] Ghost configuration file does not exist. Aborting.\033[0m"
  exit 1
fi
if [ ! -e "$summoner_config_file" ]; then
  echo -e "\033[31m[`date +%F_%H_%M_%S`] Summoner configuration file not found. Aborting.\033[0m"
  exit 1
fi

# Get Summoner and ghost configuration files
eval $(parse_yaml $summoner_config_file "summonerconf_")
eval $(parse_yaml $MINIONS_DIR/ghost/config.yml "conf_")

## Configure Ghost environment
env_file=$GHOST_DIR/.env
echo "DOMAIN=$summonerconf_summoner_domain" > $env_file
echo "VOLUME_STORAGE_ROOT=$summonerconf_summoner_vsroot" >> $env_file
echo "GHOST_VERSION=$conf_ghost_version" >> $env_file
echo "GHOST_SUBDOMAIN=$conf_ghost_subdomain" >> $env_file
echo "GHOST_WEB_PORT=$conf_ghost_port" >> $env_file

source $GHOST_DIR/.env

# Add a file to allow file download (>1Mb)
## Check if nginx is launch
if [ ! -d $VOLUME_STORAGE_ROOT/vhost.d ]; then
  echo -e "\033[31m[`date +%F_%H_%M_%S`] Please Launch nginx container first.\033[0m"
  exit 1
fi

## Add the file
if [ ! -z $GHOST_SUBDOMAIN ]; then
  echo "client_max_body_size 2000m;" >> $VOLUME_STORAGE_ROOT/vhost.d/$DOMAIN
else
  echo "client_max_body_size 2000m;" >> $VOLUME_STORAGE_ROOT/vhost.d/$GHOST_SUBDOMAIN.$DOMAIN
fi

cd $GHOST_DIR
docker-compose up -d
cd - >>/dev/null

echo -e "\033[32m[`date +%F_%H_%M_%S`] Ghost installation ended well.\033[0m"
