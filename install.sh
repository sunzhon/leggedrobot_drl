#! /bin/sh
#1)  install docker
# Add Docker's official GPG key:
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y 

sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

#sudo docker run hello-world && \

#Docker 需要用户具有 sudo 权限
sudo usermod -aG docker $USER
sudo systemctl start docker

#2) create container of ambot execution env, ambot_env:0.52  is a version of single leg control
docker image pull sunzhon/ambot_env:0.52
docker run -u root -it --name ambot -v /dev/:/dev/ --privileged sunzhon/ambot_env:0.52 /bin/bash

