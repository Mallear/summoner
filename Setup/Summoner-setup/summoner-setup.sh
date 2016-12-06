#!/bin/bash

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
  echo -e "Docker already installed, jump to Summoner installation."
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
  echo "MINIONS_DIR=~Summoner/Minions" >> $SUMMONER_CONFIG_FILE
  source $SUMMONER_CONFIG_FILE

  ## Add sourcing of Summoner config file at each log in
  echo "# Source Summoner config file"
  echo "if [ -f $SUMMONER_CONFIG_FILE ]; then" >> ~/.bashrc
  echo "  . $SUMMONER_CONFIG_FILE" >> ~/.bashrc
  echo "fi" >> ~/.bashrc

  ## Building files architecture
  mkdir -p $SUMMONER_HOME
  mkdir -p $MINIONS_DIR

else
  echo "Summoner already set up"
fi
