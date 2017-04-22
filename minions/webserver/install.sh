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

echo -e "\033[33m[`date +%F_%H_%M_%S`] Starting Statik installation.\033[0m "
STATIK_DIR=$MINIONS_DIR/statik
if [ ! -e "$STATIK_DIR/config.yml" ]; then
  echo -e "\033[31m[`date +%F_%H_%M_%S`] Statik configuration file does not exist. Aborting.\033[0m"
  exit 1
fi
if [ ! -e "$summoner_config_file" ]; then
  echo -e "\033[31m[`date +%F_%H_%M_%S`] Summoner configuration file not found. Aborting.\033[0m"
  exit 1
fi

# Get Summoner configuration file
eval $(parse_yaml $summoner_config_file "summonerconf_")
eval $(parse_yaml $MINIONS_DIR/statik/config.yml "conf_")

# Configure statik .env file
env_file=$MINIONS_DIR/statik/.env
echo "DOMAIN=$summonerconf_summoner_domain" > $env_file
echo "VOLUME_STORAGE_ROOT=$summonerconf_summoner_vsroot" >> $env_file
echo "DATABASE_STORAGE_ROOT=$summonerconf_summoner_dbsroot" >> $env_file
echo "STATIK_VERSION=$conf_statik_version" >> $env_file
echo "STATIK_SUBDOMAIN=$conf_statik_subdomain" >> $env_file
echo "STATIK_WEB_PORT=$conf_statik_port" >> $env_file
echo "STATIK_DATA_DIR=$conf_statik_data" >> $env_file

# Deploy app
cd $MINIONS_DIR/statik
docker-compose up -d
cd - >> /dev/null

echo -e "\033m[32[`date +%F_%H_%M_%S`] Statik installation ended well.\033[0m"
