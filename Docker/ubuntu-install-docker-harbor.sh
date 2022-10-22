#!/bin/bash
#Description：Ubuntu系统安装docker harbor镜像仓库
COLOR="echo -e \\033[1;31m"
END="\033[m"
DOCKER_VERSION="5:19.03.5~3-0~ubuntu-bionic"
COMPOSE_VERSION=1.25.5
COMPOSE_FILE=docker-compose-Linux-x86_64
HARBOR_VERSION=1.7.6
HARBOR_FILE=harbor-offline-installer-v1.7.6.tgz

IPADDR=hostname -I|awk '{print $1}'
HARBOR_ADMIN_PASSWORD=123456

install_docker(){
    ${COLOR}"开始安装 Docker....."${END}
    sleep 1 

    apt update
    apt  -y install apt-transport-https ca-certificates curl software-properties-common 
    curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
    add-apt-repository "deb [arch=amd64] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"
    apt update

    ${COLOR}"Docker有以下版本:"${END}
    sleep 2
    apt-cache madison docker-ce
    ${COLOR}"5秒后即将安装: docker-"${DOCKER_VERSION}" 版本....."${END}
    ${COLOR}"如果想安装其它Docker版本，请按ctrl+c键退出，修改版本再执行"${END}
    sleep 5

    apt -y  install docker-ce=${DOCKER_VERSION} docker-ce-cli=${DOCKER_VERSION}

    mkdir -p /etc/docker
    tee /etc/docker/daemon.json <uname -s-uname -m -o /usr/local/bin/docker-compose

    mv $COMPOSE_FILE /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose

    docker-compose --version &&  ${COLOR}"Docker Compose 安装完成"${END} || ${COLOR}"Docker compose 安装失败"${END}
}

install_harbor(){
    ${COLOR}"开始安装 Harbor....."${END}
    sleep 1

    #wget https://storage.googleapis.com/harbor-releases/release-1.7.0/harbor-offline-installer-v${HARBOR_VERSION}.tgz
    mkdir /apps
    tar xvf ${HARBOR_FILE}  -C /apps/
    sed -i.bak -e 's/^hostname =.*/hostname = '''$HOSTNAME'''/' -e 's/^harbor_admin_password =.*/harbor_admin_password = '''$HARBOR_ADMIN_PASSWORD'''/' /apps/harbor/harbor.cfg

    apt -y install python

    /apps/harbor/install.sh && ${COLOR}"Harbor 安装完成"${END} ||  ${COLOR}"Harbor 安装失败"${END}

}

dpkg -s docker-ce &> /dev/null && ${COLOR}"Docker已安装"${END} || install_docker

docker-compose --version &> /dev/null && ${COLOR}"Docker Compose已安装"${END} || install_docker_compose

install_harbor