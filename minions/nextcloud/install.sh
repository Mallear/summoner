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

NEXTCLOUD_DIR=$MINIONS_DIR/nextcloud
echo -e "\033[33m[`date +%F_%H_%M_%S`] Starting Nextcloud installation.\033[0m"

if [ ! -e "$NEXTCLOUD_DIR/config.yml" ]; then
  echo -e "\033[31m[`date +%F_%H_%M_%S`] Nextcloud configuration file does not exist. Aborting.\033[0m"
  exit 1
fi
if [ ! -e "$summoner_config_file" ]; then
  echo -e "\033[31m[`date +%F_%H_%M_%S`] Summoner configuration file not found. Aborting.\033[0m"
  exit 1
fi

# Get Summoner configuration file
eval $(parse_yaml $summoner_config_file "summonerconf_")
eval $(parse_yaml $MINIONS_DIR/nextcloud/config.yml "conf_")

# Configure Nextcloud environment
env_file=$MINIONS_DIR/nextcloud/.env
echo "DOMAIN=$summonerconf_summoner_domain" > $env_file
echo "VOLUME_STORAGE_ROOT=$summonerconf_summoner_vsroot" >> $env_file
echo "DATABASE_STORAGE_ROOT=$summonerconf_summoner_dbsroot" >> $env_file
echo "NEXTCLOUD_VERSION=$conf_nextcloud_version" >> $env_file
echo "NEXTCLOUD_SUBDOMAIN=$conf_nextcloud_subdomain" >> $env_file
echo "NEXTCLOUD_WEB_PORT=$conf_nextcloud_port" >> $env_file
echo "NEXTCLOUD_MARIADB_VERSION=$conf_nextcloud_db_version" >> $env_file
echo "NEXTCLOUD_DB_DATA_DIR=$conf_nextcloud_db_directory" >> $env_file
echo "NEXTCLOUD_DATA_DIR=$conf_data" >> $env_file
echo "NEXTCLOUD_CONFIG_DIR=$conf_config" >> $env_file
echo "NEXTCLOUD_APPS_DIR=$conf_nextcloud_apps" >> $env_file
echo "NEXTCLOUD_ADMIN_USER=$conf_nextcloud_admin_user" >> $env_file
echo "NEXTCLOUD_ADMIN_PASSWORD=$conf_nextcloud_admin_password" >> $env_file
echo "MYSQL_PASSWORD=$conf_nextcloud_db_password" >> $env_file
echo "MYSQL_ROOT_PASSWORD=$conf_nextcloud_db_root_password" >> $env_file
echo "MYSQL_DB_NAME=$conf_nextcloud_db_name" >> $env_file
echo "MYSQL_USER=$conf_nextcloud_db_user" >> $env_file
echo "NEXTCLOUD_REDIS_DATA=$conf_nextcloud_redis_data" >> $env_file
echo "NEXTCLOUD_SOLR_DATA=$conf_nextcloud_solr_data" >> $env_file

source $NEXTCLOUD_DIR/.env

# Add a file to allow file download (>1Mb)
## Check if nginx is launch
if [ ! -d $VOLUME_STORAGE_ROOT/vhost.d ]; then
  echo -e "\033[31m[`date +%F_%H_%M_%S`] Please Launch nginx container first.\033[0m"
  exit 1
fi

## Add the file
if [ -z $NEXTCLOUD_SUBDOMAIN ]; then
  echo "client_max_body_size 2000m;" >> $VOLUME_STORAGE_ROOT/vhost.d/$DOMAIN
else
  echo "client_max_body_size 2000m;" >> $VOLUME_STORAGE_ROOT/vhost.d/$NEXTCLOUD_SUBDOMAIN.$DOMAIN
fi

cd $NEXTCLOUD_DIR
docker-compose up -d
cd ->> /dev/null

echo -e "\033[32m[`date +%F_%H_%M_%S`] Nextcloud installation ended well.\033[0m"
