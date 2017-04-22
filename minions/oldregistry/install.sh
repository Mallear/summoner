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

GITLAB_DIR=$MINIONS_DIR/gitlab
echo -e "\033[33m[`date +%F_%H_%M_%S`] Starting Gitlab installation.\033[0m"

if [ ! -e "$GITLAB_DIR/config.yml" ]; then
  echo -e "\033[31m[`date +%F_%H_%M_%S`] Gitlab configuration file does not exist. Aborting.\033[0m"
  exit 1
fi
if [ ! -e "$summoner_config_file" ]; then
  echo -e "\033[31m[`date +%F_%H_%M_%S`] Summoner configuration file not found. Aborting.\033[0m"
  exit 1
fi

# Get Summoner configuration file
eval $(parse_yaml $summoner_config_file "summonerconf_")
eval $(parse_yaml $MINIONS_DIR/gitlab/config.yml "conf_")

# Configure Gitlab environment
env_file=$MINIONS_DIR/gitlab/.env
echo "DOMAIN=$summonerconf_summoner_domain" > $env_file
echo "VOLUME_STORAGE_ROOT=$summonerconf_summoner_vsroot" >> $env_file
echo "DATABASE_STORAGE_ROOT=$summonerconf_summoner_dbsroot" >> $env_file
echo "GITLAB_VERSION=$conf_gitlab_version" >> $env_file
echo "GITLAB_SUBDOMAIN=$conf_gitlab_subdomain" >> $env_file
echo "GITLAB_WEB_PORT=$conf_gitlab_port" >> $env_file
echo "GITLAB_MARIADB_VERSION=$conf_gitlab_db_version" >> $env_file
echo "GITLAB_DB_DATA_DIR=$conf_gitlab_db_directory" >> $env_file
echo "GITLAB_DATA_DIR=$conf_data" >> $env_file
echo "GITLAB_CONFIG_DIR=$conf_config" >> $env_file
echo "GITLAB_APPS_DIR=$conf_gitlab_apps" >> $env_file
echo "GITLAB_ADMIN_USER=$conf_gitlab_admin_user" >> $env_file
echo "GITLAB_ADMIN_PASSWORD=$conf_gitlab_admin_password" >> $env_file
echo "MYSQL_PASSWORD=$conf_gitlab_db_password" >> $env_file
echo "MYSQL_ROOT_PASSWORD=$conf_gitlab_db_root_password" >> $env_file
echo "MYSQL_DB_NAME=$conf_gitlab_db_name" >> $env_file
echo "MYSQL_USER=$conf_gitlab_db_user" >> $env_file

source $GITLAB_DIR/.env

# Add a file to allow file download (>1Mb)
## Check if nginx is launch
if [ ! -d $VOLUME_STORAGE_ROOT/vhost.d ]; then
  echo -e "\033[31m[`date +%F_%H_%M_%S`] Please Launch nginx container first.\033[0m"
  exit 1
fi

cd $GITLAB_DIR
docker-compose up -d
cd ->> /dev/null

echo -e "\033[32m[`date +%F_%H_%M_%S`] Gitlab installation ended well.\033[0m"
