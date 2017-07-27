#!/bin/bash

source config
./install/downloadClientFile.sh

sudo cp -r create-certs/$CA_DIR /srv/

./install/installKubelet.sh
./install/installKubeProxy.sh
./install/installFlannel.sh

