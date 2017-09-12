#!/bin/bash
git clone https://github.com/cloudfoundry/cf-release.git
cd cf-release
# git checkout v265
./scripts/update
gem install bundler
cd ..
wget https://github.com/cloudfoundry-incubator/spiff/releases/download/v1.0.8/spiff_linux_amd64.zip
sudo apt-get install -y zip
unzip spiff_linux_amd64.zip
cp spiff /usr/local/bin/
cd cf-release/
./scripts/generate-bosh-lite-dev-manifest
cd ..
wget -O stemcell.tgz https://s3.amazonaws.com/bosh-core-stemcells/warden/bosh-stemcell-3431.10-warden-boshlite-ubuntu-trusty-go_agent.tgz
bosh upload stemcell stemcell.tgz
cd cf-release/
bosh -n create release

bosh -n upload release
bosh -n deploy