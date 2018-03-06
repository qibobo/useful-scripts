#!/bin/bash

# requirements:
# kubectl
# helm
# bx cli
# cf cli
# jq
# fissile
# docker
# bosh
# git
# golang

echo "==========update repo===========\n" \
&& sudo apt-get update \

&& echo "==========install vim ===========\n" \
&& sudo apt-get install -y vim \

&& echo "==========install golang ==========" \
&& sudo wget https://dl.google.com/go/go1.10.linux-amd64.tar.gz \
&& tar -C /usr/local -xzf go1.10.linux-amd64.tar.gz \
&& export PATH=$PATH:/usr/local/go/bin \
&& go version \

&& echo "==========install git===========\n" \
&& sudo apt-get install -y git \
&& ./docker/installdocker.sh \

&& echo "===============install jq==================" \
&& sudo apt-get install -y jq \
&& sudo apt-get install -y rubygems build-essential \
&& gem install bosh_cli --no-ri --no-rdoc \

&& echo "===============install bosh_cli_v2==================" \
&& sudo wget https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-2.0.45-linux-amd64 \
&& sudo mv bosh-cli-* /usr/local/bin/bosh2  \
&& sudo chmod +x /usr/local/bin/bosh2 \

&& echo "===============install cf cli=======================" \
&& sudo wget -O cli_linux.tgz https://packages.cloudfoundry.org/stable?release=linux64-binary&source=github  \
&& sudo tar -xvf cli_linux.tgz \
&& sudo mv cf /usr/local/bin \
&& cf --version \

&& echo "===============install ibm cloud cli================" \
&& sudo wget -O bmxcli_linux.tgz https://clis.ng.bluemix.net/download/bluemix-cli/latest/linux64  \
&& sudo tar -xvf bmxcli_linux.tgz \
&& sudo ./Bluemix_CLI/install_bluemix_cli \

&& echo "===============install kubectl===============" \
&& sudo curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
&& sudo chmod +x ./kubectl \
&& sudo mv ./kubectl /usr/local/bin/kubectl \
&& echo "===============install helm===============" \
&& sudo wget https://kubernetes-helm.storage.googleapis.com/helm-v2.8.1-linux-amd64.tar.gz \
&& sudo tar -xvf helm-v2.8.1-linux-amd64.tar.gz \
&& sudo chmod +x ./linux-amd64/helm \
&& sudo mv ./linux-amd64/helm /usr/local/bin/helm \
&& helm version \
&& echo "===============install fissile===============" \
&& export GOPATH=$PWD \
&& go get -d github.com/SUSE/fissile \
&& cd $GOPATH/src/github.com/SUSE/fissile \
&& make tools \
&& make docker-deps \
&& make all

