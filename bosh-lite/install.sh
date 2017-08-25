#!/bin/bash
echo "===============install git=================="
sudo apt-get install -y git
echo "===============install gem=================="
sudo apt-get install -y rubygems build-essential
echo "===============install bosh_cli=================="
gem install bosh_cli --no-ri --no-rdoc
echo "===============install virtualbox=================="
#need virtualbox 5.1+ since previous versions had a network connectivity bug.
sudo apt remove virtualbox virtualbox-5.0 virtualbox-4.*
sudo sh -c 'echo "deb http://download.virtualbox.org/virtualbox/debian xenial contrib" >> /etc/apt/sources.list.d/virtualbox.list'
wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
sudo apt update
sudo apt-get install -y virtualbox-5.1

wget -O vagrant_1.9.7.deb https://releases.hashicorp.com/vagrant/1.9.7/vagrant_1.9.7_x86_64.deb?_ga=2.56676585.2117853575.1501557372-1114066615.1500372577
dpkg -i vagrant_1.9.7.deb

# wget -O virtualbox-5.1.deb http://download.virtualbox.org/virtualbox/5.1.26/virtualbox-5.1_5.1.26-117224~Ubuntu~xenial_amd64.deb
# dpkg -i virtualbox-5.1.deb


cd /root
mkdir workspace
cd workspace
git clone https://github.com/cloudfoundry/bosh-lite
cd bosh-lite
vagrant up --provider=virtualbox
bosh target 192.168.50.4 lite
bin/add-route

cd ..
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

cd ..
git clone https://github.com/cloudfoundry/diego-release.git
cd diego-release
./scripts/update
./scripts/generate-bosh-lite-manifests
bosh upload release https://bosh.io/d/github.com/cloudfoundry/garden-runc-release
bosh upload release https://bosh.io/d/github.com/cloudfoundry/cflinuxfs2-release
bosh deployment bosh-lite/deployments/diego.yml
bosh -n create release --force
bosh -n upload release
bosh -n deploy

cd ..
git clone https://github.com/cloudfoundry-incubator/app-autoscaler-release
cd app-autoscaler-release
./scripts/update
bosh update cloud-config ./example/cloud-config.yml
./scripts/generate-bosh-lite-manifest -c ../cf-release/bosh-lite/deployments/cf.yml -p ./example/property-overrides.yml
./scripts/deploy

cd ..
wget -O cfcli.deb https://cli.run.pivotal.io/stable?release=debian64&source=github
dpkg -i cfcli.deb
cf login -a https://api.bosh-lite.com -u admin -p admin --skip-ssl-validation
cf create-service-broker autoscaler username password https://servicebroker.service.cf.internal:6101
cf enable-service-access autoscaler

cat > integration_config.json <<EOF
{
  "api": "api.bosh-lite.com",
  "admin_user": "admin",
  "admin_password": "admin",
  "apps_domain": "bosh-lite.com",
  "skip_ssl_validation": true,
  "use_http": true,

  "service_name": "autoscaler",
  "service_plan": "autoscaler-free-plan",
  "aggregate_interval": 120
}
EOF
export CONFIG=$PWD/integration_config.json
wget https://storage.googleapis.com/golang/go1.8.3.linux-amd64.tar.gz
cp -R go /usr/local
export PATH=$PATH:/usr/local/go/bin
cd app-autoscaler-release
source .envrc
cd src/acceptance
./bin/test_default



