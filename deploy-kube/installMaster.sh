#!/bin/bash

source config
./install/downloadServerFile.sh

sudo cp -r create-certs/$CA_DIR /srv/

./install/installEtcd.sh
./install/installKubeApiServer.sh
./install/installKubeControllerManager.sh
./install/installKubeScheduler.sh


