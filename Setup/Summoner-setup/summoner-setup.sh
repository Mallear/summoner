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


nginx_conf() {
    ## Configure Nginx reverse proxy
    echo "DOMAIN=$conf_domain" > $MINIONS_DIR/nginx/.env
    echo "VOLUME_STORAGE_ROOT=$conf_vsroot" >> $MINIONS_DIR/nginx/.env
    echo "NGINX_VERSION=$conf_nginx_version" >> $MINIONS_DIR/nginx/.env
    echo "LETSENCRYPT_VERSION=$conf_nginx_letsencrypt_version" >> $MINIONS_DIR/nginx/.env
    echo "CERT_DIR=$conf_nginx_cert_directory" >> $MINIONS_DIR/nginx/.env
    echo "VHOST_DIR=$conf_nginx_vhost_dir" >> $MINIONS_DIR/nginx/.env
}

wekan_conf(){
    ## Configure Wekan environment
    env_file=$MINIONS_DIR/wekan/.env
    echo "DOMAIN=$conf_domain" > $env_file
    echo "VOLUME_STORAGE_ROOT=$conf_vsroot" >> $env_file
    echo "WEKAN_VERSION=$conf_wekan_version" >> $env_file
    echo "WEKAN_SUBDOMAIN=$conf_wekan_subdomain" >> $env_file
    echo "WEKAN_WEB_PORT=$conf_wekan_port" >> $env_file
    echo "WEKAN_MONGODB_VERSION=$conf_wekan_db_version" >> $env_file
    echo "WEKAN_DB_DATA_DIR=$conf_wekan_db_directory" >> $env_file
}

nextcloud_conf(){
  # Configure Nextcloud environment
  env_file=$MINIONS_DIR/nextcloud/.env
  echo "DOMAIN=$conf_domain" > $env_file
  echo "VOLUME_STORAGE_ROOT=$conf_vsroot" >> $env_file
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
}

ghost_conf(){
  ## Configure Ghost environment
  env_file=$MINIONS_DIR/ghost/.env
  echo "DOMAIN=$conf_domain" > $env_file
  echo "VOLUME_STORAGE_ROOT=$conf_vsroot" >> $env_file
  echo "GHOST_VERSION=$conf_ghost_version" >> $env_file
  echo "GHOST_SUBDOMAIN=$conf_ghost_subdomain" >> $env_file
  echo "GHOST_WEB_PORT=$conf_ghost_port" >> $env_file
}


SUMMONER_CONFIG_FILE=$HOME/.summoner

# Check kernel version
KERNEL_MAJOR=`uname -r | tr '-' ' ' | tr '.' ' ' | cut -d ' ' -f 1`
KERNEL_MINOR=`uname -r | tr '-' ' ' | tr '.' ' ' | cut -d ' ' -f 2`

if [ $KERNEL_MAJOR -lt 3 ]; then
  if [ $KERNEL_MINOR -lt 10 ]; then
    echo -e "Your kernel version is lower than 3.10. Docker can't be installed."
    echo -e "Please update your kernel version and try again."
    echo -e "For more information : https://gitlab.com/puzle-project/Summoner"
    exit 1
  fi
fi

# Check if Docker is already installed
if [ `dpkg -s docker-engine | grep -i status | wc -l ` -eq 1 ]; then
  echo -e "Docker already installed, jump to compose installation."
else
  echo -e "Docker-engine not yet installed."
  echo -e "Installation begins ..."

  ## Check distribution
  CHECK_UBUNTU=`lsb_release -a | grep -i ubuntu | wc -l`
  CHECK_DEBIAN=`lsb_release -a | grep -i debian | wc -l`
  VERSION=`lsb_release -a | grep -i release | tr ':' ' ' | cut -d ' ' -f2 | tr -d '[:space:]'`
  VERSION_MAJOR=`echo $VERSION | cut -d '.' -f1`
  VERSION_MINOR=`echo $VERSION | cut -d '.' -f2`
  CODENAME=`lsb_release -a | grep -i codename | tr ':' ' ' | cut -d ' ' -f 2 | tr -d '[:space:]'`

  ## Ubuntu setup
  if [ $CHECK_UBUNTU -ne 0 ]; then
    # Managing install on 12.04 -> fail
    if [ $VERSION_MAJOR -eq 12 ] && [ $VERSION_MINOR -eq 04 ]; then
      echo -e "Your currently running an Ubuntu 12.04 LTS version"
      echo -e "Please upgrade your OS version to a more recent version and try installing Summoner again."
      exit 1
    fi

    apt-get update
    apt-get install -y apt-transport-https ca-certificates
    # Add new GPG key
    apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
    # Add docker sources repo according to Ubuntu version
    echo "deb https://apt.dockerproject.org/repo ubuntu-$CODENAME main" > /etc/apt/sources.list.d/docker.list
    apt-get update
    apt-get purge lxc-docker*
    apt-cache policy docker-engine

    # Install linux-image-extra for aufs managing
    apt-get update
    apt-get install -y linux-image-extra-$(uname-r)
  fi


  ## Debian setup
  if [ $CHECK_DEBIAN -ne 0 ]; then
    if [ "$CODENAME" -eq "wheezy" ]; then
      ## Opening backports for Wheezy
      echo "deb http:/http.debian.net/debian $CODENAME-backports main" > /etc/apt/sources.list.d/backports.list
      apt-get update
    fi

    apt-get purge lxc-docker*
    apt-get purge docker.io*
    apt-get update
    apt-get install -y apt-transport-https ca-certificates
    apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

    echo "deb https://apt.dockerproject.org/repo debian-$CODENAME main" > /etc/apt/sources.list.d/docker.list
    apt-get update
    apt-cache policy docker-engine
  fi

  ## Docker installation

  apt-get update
  apt-get install -y docker-engine
  service docker start
  CHECK_INSTALL=`docker run hello-world | grep -i "hello from docker" | wc -l`

  if [ $CHECK_INSTALL -eq 1 ]; then
    echo -e "Docker engine install - OK !"
  else
    echo -e "Docker engine install - KO !"
    echo -e "Summoner installation - KO !"
    echo -e "Please see logs for further informations"
    exit 1
  fi
fi

# Checking docker-compose installation
if [ `dpkg -s docker-compose | grep -i status | wc -l` -eq 1 ]; then
  echo -e "Docker compose already installed. Jump to Summoner installation."
else
  echo -e "Docker compose not yet installed."
  echo -e "Docker compose installation begins ..."

  if [ ! `dpkg -s curl | grep -i status | wc -l` -eq 1]; then
    apt-get install -y curl
  fi

  curl -L "https://github.com/docker/compose/releases/download/1.9.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
  echo -e "docker-compose installation - OK !"
  docker-compose --version
fi

# Summoner installation
if [ ! -e "$SUMMONER_CONFIG_FILE" ]; then

  if [ ! -e "~/.dropbox_uploader" ]; then
    echo "OAUTH_ACCESS_TOKEN=NzqGcqMR5HAAAAAAAAAAYejJ-G8hpryFVIXqB0uF4mflHzyiEHpCfwbgN_d7GW75" > ~/.dropbox_uploader
  fi

  echo "SUMMONER_HOME=~/Summoner" >> $SUMMONER_CONFIG_FILE
  echo "MINIONS_DIR=~/Summoner/Minions" >> $SUMMONER_CONFIG_FILE
  source $SUMMONER_CONFIG_FILE

  ## Add sourcing of Summoner config file at each log in
  echo "Source Summoner config file"
  echo "if [ -f $SUMMONER_CONFIG_FILE ]; then" >> ~/.bashrc
  echo "  . $SUMMONER_CONFIG_FILE" >> ~/.bashrc
  echo "fi" >> ~/.bashrc

  ## Building files architecture
  mkdir -p $SUMMONER_HOME
  mkdir -p $MINIONS_DIR

  ## Get all the git repository for the apps to install
  eval $(parse_yaml conf.yml "conf_")

  ## Nginx have to be the first of all apps deployed
  if [[ ! -z "$conf_apps_nginx" ]]; then
    SUMMONER_TOOLS+=" nginx"
    SUMMONER_TOOLS_URLS+=" git@gitlab.com:puzle-project/Summoner-nginx.git"
  fi

  if [[ ! -z "$conf_apps_wekan" ]]; then
    SUMMONER_TOOLS+=" wekan"
    SUMMONER_TOOLS_URLS+=" git@gitlab.com:puzle-project/Summoner-wekan.git"
  fi

  if [ ! -z "$conf_apps_nextcloud" ]; then
    SUMMONER_TOOLS+=" nextcloud"
    SUMMONER_TOOLS_URLS+=" git@gitlab.com:puzle-project/Summoner-nextcloud.git"
  fi

  if [ ! -z "$conf_apps_ghost" ]; then
    SUMMONER_TOOLS+=" ghost"
    SUMMONER_TOOLS_URLS+=" git@gitlab.com:puzle-project/Summoner-ghost.git"
  fi

  IFS=' ' read -r -a SUMMONER_TOOLS <<< "$SUMMONER_TOOLS"
  IFS=' ' read -r -a SUMMONER_TOOLS_URLS <<< "$SUMMONER_TOOLS_URLS"

  echo -e "Getting all sources from Git"
  ## Git clone sources
  for (( t=0; t<${#SUMMONER_TOOLS_URLS[@]}; t++ )) do
    echo -e "Getting tool : ${SUMMONER_TOOLS[$t]} - $(($t+1))/${#SUMMONER_TOOLS_URLS[@]}"
    git clone ${SUMMONER_TOOLS_URLS[$t]} $MINIONS_DIR/${SUMMONER_TOOLS[$t]}
    SUMMONER_TOOLS_DEPLOY+=" ${SUMMONER_TOOLS[$t]}"
  done

  # Configuration of apps
  nginx_conf
  wekan_conf
  nextcloud_conf
  ghost_conf

    ## Deploying Apps : nginx first
    echo -e "Deploying apps ..."
  for (( t=0; t<${#SUMMONER_TOOLS[@]}; t++ )) do
    echo -e "Starting : ${SUMMONER_TOOLS[$t]}"
    cd $MINIONS_DIR/${SUMMONER_TOOLS[$t]}
    docker-compose up -d
    cd - >> /dev/null
  done

else
  echo "Summoner already set up"
fi
