#!/bin/bash

install_docker_ubuntu() {
    # Remove old versions of engine
    apt-get remove docker docker-engine

    # Update repositories
    apt-get update

    # Install extra packages
    apt-get install \
        linux-image-extra-$(uname -r) \
        linux-image-extra-virtual

    # Install packages to use repositories over HTTPS
    apt-get install \
        apt-transport-https \
        ca-certificates \
        curl \
        software-properties-common

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -


    #if [ `apt-key fingerprint 0EBFCD88` -ne `9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88` ]; then
    #    echo "Docker installation failed when adding Docker's official GPG key."
    #fi

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
    apt-get update
    apt-get install docker-ce
    apt-cache madison docker-ce

    ## Check Docker installation
    CHECK_INSTALL=`docker run hello-world | grep -i "hello from docker" | wc -l`

    if [ $CHECK_INSTALL -eq 1 ]; then
        echo -e "\033[32m[`date +%F_%H_%M_%S`]Docker engine install - OK !"
    else
        echo -e "\033[31m[`date +%F_%H_%M_%S`] Docker engine install - KO !"
        echo -e "\033[31m[`date +%F_%H_%M_%S`] Summoner installation - KO !"
        echo -e "\033[31m[`date +%F_%H_%M_%S`] Please see logs for further informations"
        exit 1
    fi
}