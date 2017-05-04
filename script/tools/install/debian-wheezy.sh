#!/bin/bash

install_docker_wheezy(){
    # Remove old versions of engine
    apt-get -y remove docker docker-engine

    ## Opening backports for Wheezy
      echo "deb http:/http.debian.net/debian $CODENAME-backports main" > /etc/apt/sources.list.d/backports.list
      apt-get update -y

    # Install packages to use repositories over HTTPS
    apt-get -y install \
         apt-transport-https \
         ca-certificates \
         curl \
         python-software-properties

    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
    apt-key fingerprint 0EBFCD88

    if [ `dpkg --print-architecture` == "amd64" ]; then 
        add-apt-repository \
            "deb [arch=amd64] https://download.docker.com/linux/debian \
            $(lsb_release -cs) \
            stable"
    elif [ `dpkg --print-architecture` == "armhf" ]; then
        echo "deb [arch=armhf] https://download.docker.com/linux/debian \
            $(lsb_release -cs) stable" | \
            tee /etc/apt/sources.list.d/docker.list
    fi

    # Install last Docker CE version
    apt-get update -y
    apt-get install -y docker-ce
    apt-cache madison docker-ce

    ## Check Docker installation
    if [ `dpkg --print-architecture` == "amd64" ]; then 
        CHECK_INSTALL=`docker run hello-world | grep -i "hello from docker" | wc -l`
    elif [ `dpkg --print-architecture` == "armhf" ]; then
        CHECK_INSTALL=`docker run armhf/hello-world | grep -i "hello from docker" | wc -l`
    fi

    if [ $CHECK_INSTALL -eq 1 ]; then
        echo -e "\033[32m[`date +%F_%H_%M_%S`]Docker engine install - OK !"
    else
        echo -e "\033[31m[`date +%F_%H_%M_%S`] Docker engine install - KO !"
        echo -e "\033[31m[`date +%F_%H_%M_%S`] Summoner installation - KO !"
        echo -e "\033[31m[`date +%F_%H_%M_%S`] Please see logs for further informations"
        exit 1
    fi
}