#!/bin/bash

# import common functions
. `pwd`/script/tools/common.sh
. `pwd`/script/tools/install/ubuntu.sh
. `pwd`/script/tools/install/debian-wheezy.sh

SUMMONER_CONTEXT_FILE=$HOME/.summoner

echo -e "\033[33m[`date +%F_%H_%M_%S`] Start Summoner installation"

# Check kernel version
KERNEL_MAJOR=`uname -r | tr '-' ' ' | tr '.' ' ' | cut -d ' ' -f 1`
KERNEL_MINOR=`uname -r | tr '-' ' ' | tr '.' ' ' | cut -d ' ' -f 2`

if [ $KERNEL_MAJOR -lt 3 ]; then
  if [ $KERNEL_MINOR -lt 10 ]; then
    echo -e "\033[31m[`date +%F_%H_%M_%S`] Your kernel version is lower than 3.10. Docker can't be installed."
    echo -e "\033[31m[`date +%F_%H_%M_%S`] Please update your kernel version and try again."
    echo -e "\033[31m[`date +%F_%H_%M_%S`] For more information : https://gitlab.com/puzle-project/Summoner"
    exit 1
  fi
fi

apt-get install -y dpkg

# Check if Docker is already installed
if [ `dpkg -s docker-engine | grep -i status | wc -l ` -eq 1 ]; then
  echo -e "\033[32m[`date +%F_%H_%M_%S`] Docker already installed, jump to compose installation."
else
  echo -e "\033[33m[`date +%F_%H_%M_%S`] Docker-engine not yet installed."
  echo -e "\033[33m[`date +%F_%H_%M_%S`] Installation begins ..."

  ## Install ldb_release command
  # apt-get update -y
  apt-get install -y lsb-release

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

    install_docker_ubuntu    
  fi

  ## Debian setup
  if [ $CHECK_DEBIAN -ne 0 ]; then
    install_docker_wheezy
  fi

fi

# Checking docker-compose installation
if [ `dpkg -s docker-compose | grep -i status | wc -l` -eq 1 ]; then
  echo -e "\033[32m[`date +%F_%H_%M_%S`] Docker compose already installed. Jump to Summoner installation."
else
  echo -e "\033[33m[`date +%F_%H_%M_%S`] Docker compose not yet installed."
  echo -e "\033[33m[`date +%F_%H_%M_%S`] Docker compose installation begins ..."

  if [ ! `dpkg -s curl | grep -i status | wc -l` -eq 1 ]; then
    apt-get install -y curl
  fi

  curl -L "https://github.com/docker/compose/releases/download/1.9.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
  echo -e "\033[32m[`date +%F_%H_%M_%S`] docker-compose installation - OK !"
  docker-compose --version
fi

# Summoner installation
if [ ! -e "$SUMMONER_CONTEXT_FILE" ]; then

  ### Variable definitions
  config_file=~/Summoner/config.yml # configuration file of summoner
  dbbackup_script_relativ=script/backup/database-backup.sh
  dbdump_script_relativ=script/dump/dump.sh
  data_backup_script_relativ=script/backup/data-backup.sh

  # Check if the config file is here
  if [ ! -e "$config_file" ]; then
    echo -e "\033[31m[`date +%F_%H_%M_%S`] Summoner config file is not set. Aborting."
    exit 1
  fi

  # Parse the summoner config file
  eval $(parse_yaml $config_file "conf_")

  if [ ! -e "~/.dropbox_uploader" ]; then
    echo "OAUTH_ACCESS_TOKEN=$conf_summoner_dropbox_token" > ~/.dropbox_uploader
  fi

  # Set .summoner file
  echo "SUMMONER_HOME=~/Summoner" >> $SUMMONER_CONTEXT_FILE
  echo "MINIONS_DIR=~/Summoner/minions" >> $SUMMONER_CONTEXT_FILE
  echo "VOLUME_STORAGE_ROOT=$conf_summoner_vsroot" >> $SUMMONER_CONTEXT_FILE
  echo "DATABASE_STORAGE_ROOT=$conf_summoner_dbsroot" >> $SUMMONER_CONTEXT_FILE
  echo "SUMMONER_CONFIG_FILE=$config_file" >> $SUMMONER_CONTEXT_FILE
  source $SUMMONER_CONTEXT_FILE

  ## Add sourcing of Summoner config file at each log in
  echo -e "\033[33m[`date +%F_%H_%M_%S`] Source Summoner config file"
  echo "if [ -f $SUMMONER_CONTEXT_FILE ]; then" >> ~/.bashrc
  echo "  . $SUMMONER_CONTEXT_FILE" >> ~/.bashrc
  echo "fi" >> ~/.bashrc

  ## Building files architecture
  mkdir -p $SUMMONER_HOME
  mkdir -p $MINIONS_DIR

  # Adding backup & dump to cron
  ## Creating log directory
  mkdir -p $SUMMONER_HOME/logs
  ## backup one time each month
  cd /var/spool/cron/crontabs
  SCRIPT=$SUMMONER_HOME/$dbbackup_script_relativ
  echo -e "\033[33m[`date +%F_%H_%M_%S`] Set $SCRIPT in the crontab"
  if [ `grep $SCRIPT * | wc -l` -eq 0 ]; then
    (crontab -l 2>/dev/null; echo "* 2 1 * * $SCRIPT >> ~/Summoner/logs/database-backup.log") | crontab -
  fi
  ## dump one time each week
  SCRIPT=$SUMMONER_HOME/$dbdump_script_relativ
  echo -e "\033[33m[`date +%F_%H_%M_%S`] Set $SCRIPT in the crontab"
  if [ `grep $SCRIPT * | wc -l` -eq 0 ]; then
    (crontab -l 2>/dev/null; echo "0 2 * * 7 $SCRIPT >> ~/Summoner/logs/database-dump.log") | crontab -
  fi
  ## data backup one time each month
  SCRIPT=$SUMMONER_HOME/$data_backup_script_relativ
  echo -e "\033[33m[`date +%F_%H_%M_%S`] Set $SCRIPT in the crontab"
  if [ `grep $SCRIPT * | wc -l` -eq 0 ]; then
    (crontab -l 2>/dev/null; echo "0 2 1 * * $SCRIPT >> ~/Summoner/logs/data-backup.log") | crontab -
  fi
  cd - >> /dev/null


  ## Install first apps
  ### Get all application to deploy in an array
  IFS=' ' read -r -a SUMMONER_TOOLS <<< "$conf_summoner_applications"
  for (( t=0; t<${#SUMMONER_TOOLS[@]}; t++ )) do
    # Using minions install script
    script/tools/summon.sh ${SUMMONER_TOOLS[$t]}
  done


  echo -e "\033[32m[`date +%F_%H_%M_%S`] Summoner installation OK \033[0m"
else
  echo -e "\033[32m[`date +%F_%H_%M_%S`] Summoner already set up"
fi
