#!/bin/bash

# NOT TESTED YET

install_docker_centos() {
    # Remove old versions of engine
    yum remove docker \
                  docker-common \
                  container-selinux \
                  docker-selinux \
                  docker-engine

    # Install docker
    yum install -y yum-utils
    yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

    yum-config-manager --disable docker-ce-edge

    yum makecache -y fast
    yum install docker-ce
    systemctl start docker

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