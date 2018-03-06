#!/bin/bash
##install docker
echo "===========remove old docker version" \
&& sudo apt-get remove docker docker-engine docker.io \
&& echo "===========begin to install" \
&& sudo apt-get update \
&& sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
&& curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - \
&& sudo apt-key fingerprint 0EBFCD88 \
&& sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable" \
&& sudo apt-get update \
&& sudo apt-get install -y docker-ce \
&& echo "============begin to install docker compose" \
&& sudo curl -L https://github.com/docker/compose/releases/download/1.14.0/docker-compose-`uname -s`-`uname -m` -o ./docker-compose \
&& sudo mv ./docker-compose  /usr/local/bin/docker-compose \
&& sudo chmod +x /usr/local/bin/docker-compose \
&& sudo docker-compose --version
