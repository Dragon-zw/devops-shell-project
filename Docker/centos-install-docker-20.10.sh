#!/bin/bash
# Shell ENV
DOCKER_VERSION="20.10.7"
CONTAINERD_VERSION="1.4.6"

# step 1: 安装必要的一些系统工具
echo -e "==> 安装必要的系统工具"
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
# Step 2: 添加软件源信息
echo -e "==> 添加软件源信息"
sudo yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
# Step 3
echo -e "==> 修改配置文件"
sudo sed -i 's+download.docker.com+mirrors.aliyun.com/docker-ce+' /etc/yum.repos.d/docker-ce.repo
# Step 4: 更新并安装Docker-CE
echo -e "==> 安装更新Docker"
sudo yum makecache fast
# containerd.io Docker运行时环境
sudo yum -y install docker-ce-${DOCKER_VERSION} docker-ce-cli-${DOCKER_VERSION} containerd.io-${CONTAINERD_VERSION}
# Step 5: 配置加速器以及docker参数
echo -e "==> 配置加速器以及docker参数"
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://po13h3y1.mirror.aliyuncs.com","http://hub-mirror.c.163.com","https://mirror.ccs.tencentyun.com","http://f1361db2.m.daocloud.io"],
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
# Step 6: 加载服务
echo -e "==> 加载服务"
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl enable docker
# 查看Docker服务信息
echo -e "==> 查看Docker服务信息"
docker info