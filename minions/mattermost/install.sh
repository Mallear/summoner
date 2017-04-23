#!/bin/bash

mattermost_conf(){
  ## Configure Ghost environment
  env_file=$MINIONS_DIR/mattermost/.env
  echo "DOMAIN=$conf_domain" > $env_file
  echo "VOLUME_STORAGE_ROOT=$conf_vsroot" >> $env_file
  echo "MATTERMOST_VERSION=$conf_mattermost_version" >> $env_file
  echo "MATTERMOST_MYSQL_VERSION=$conf_mattermost_db_version" >> $env_file
  echo "MATTERMOST_SUBDOMAIN=$conf_mattermost_subdomain" >> $env_file
  echo "MATTERMOST_WEB_PORT=$conf_mattermost_port" >> $env_file
  echo "MATTERMOST_DB_DATA_DIR=$conf_mattermost_db_directory" >> $env_file
  echo "MATTERMOST_DATA_DIR=$conf_mattermost_data" >> $env_file
  echo "MYSQL_PASSWORD=$conf_mattermost_db_password" >> $env_file
  echo "MYSQL_USER=$conf_mattermost_db_user" >> $env_file
  echo "MYSQL_DATABASE=$conf_mattermost_db_name" >> $env_file
  echo "MYSQL_ROOT_PASSWORD=$conf_mattermost_db_root_password" >> $env_file
}
