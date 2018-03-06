#!/bin/bash
echo "===============install git=================="
sudo apt-get install -y git
echo "===============install gem=================="
sudo apt-get install -y rubygems build-essential
echo "===============install bosh_cli=================="
gem install bosh_cli --no-ri --no-rdoc
echo "===============install bosh_cli_v2=================="
wget https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-2.0.45-linux-amd64 && \
mv bosh-cli-* /usr/local/bin/bosh2 && \
chmod +x /usr/local/bin/bosh2
echo "==============fly cli=============================="
wget https://github.com/concourse/concourse/releases/download/v3.4.1/fly_linux_amd64 \
&& chmod +x fly* \
&& mv fly* /usr/local/bin/fly
echo "===============install virtualbox=================="
#need virtualbox 5.1+ since previous versions had a network connectivity bug.
sudo apt remove virtualbox virtualbox-5.0 virtualbox-4.*
sudo apt remove -y virtualbox-5.1
sudo sh -c 'echo "deb http://download.virtualbox.org/virtualbox/debian xenial contrib" >> /etc/apt/sources.list.d/virtualbox.list'
wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
sudo apt update
sudo apt-get install -y virtualbox-5.1


wget -O vagrant_1.9.7.deb https://releases.hashicorp.com/vagrant/1.9.7/vagrant_1.9.7_x86_64.deb?_ga=2.56676585.2117853575.1501557372-1114066615.1500372577
dpkg -i vagrant_1.9.7.deb

# wget -O virtualbox-5.1.deb http://download.virtualbox.org/virtualbox/5.1.26/virtualbox-5.1_5.1.26-117224~Ubuntu~xenial_amd64.deb
# dpkg -i virtualbox-5.1.deb

## init bosh-lite
git clone https://github.com/cloudfoundry/bosh-deployment
cd bosh-deployment
cat >external_ip.yml <<-EOF
- type: replace
  path: /variables/name=director_ssl/options/alternative_names/-
  value: 10.121.94.103
EOF

bosh2 create-env bosh.yml \
  --state ./state.json \
  -o virtualbox/cpi.yml \
  -o virtualbox/outbound-network.yml \
  -o bosh-lite.yml \
  -o bosh-lite-runc.yml \
  -o jumpbox-user.yml \
  -o external_ip.yml \
  --vars-store ./creds.yml \
  -v director_name="Bosh Lite Director" \
  -v internal_ip=192.168.50.6 \
  -v internal_gw=192.168.50.1 \
  -v internal_cidr=192.168.50.0/24 \
  -v outbound_network_name=NatNetwork \
  -v admin_password=admin 
##=================2
bosh2 delete-env bosh.yml \
  --state ./state.json \
  -o virtualbox/cpi.yml \
  -o virtualbox/outbound-network.yml \
  -o bosh-lite.yml \
  -o bosh-lite-runc.yml \
  -o jumpbox-user.yml \
  -o external_ip.yml \
  --vars-store ./creds.yml \
  -v director_name="Bosh Lite Director2" \
  -v internal_ip=192.168.51.6 \
  -v internal_gw=192.168.51.1 \
  -v internal_cidr=192.168.51.0/24 \
  -v outbound_network_name=NatNetwork \
  -v admin_password=admin

## two way to connect bosh director
#1 use ca
bosh2 -e 192.168.50.6 --ca-cert <(bosh2 int /root/workspace/useful-scripts/bosh-lite/bosh-deployment/creds.yml --path /director_ssl/ca) alias-env vbox
export BOSH_ENVIRONMENT=vbox
# bosh2 -e 10.121.94.103 --ca-cert <(bosh2 int ./creds.yml --path /director_ssl/ca) alias-env vbox
# bosh2 -e 192.168.50.6 --ca-cert <(bosh2 int ./creds.yml --path /director_ssl/ca) alias-env vbox
#2 use user&pwd,BOSH_CLIENT and BOSH_CLIENT_SECRET must be set to ENV 
# export BOSH_CLIENT=admin \
# && export BOSH_CLIENT_SECRET=`bosh2 int ./creds.yml --path /admin_password` 
export BOSH_CLIENT=admin \
&& export BOSH_CLIENT_SECRET=admin 

# export BOSH_CLIENT=admin \
# && export BOSH_CLIENT_SECRET=t68sk2haqsmbl7z4bmpn 
# bosh2 -e vbox l
# vim /etc/rc.local
# ubuntu: sudo route add -net 10.244.0.0/16 gw 192.168.50.6 \
#              route add -net 9.0.0.0 netmask 255.0.0.0 gw 10.121.94.97
# mac sudo route add -net 10.244.0.0/16     192.168.50.6
# sudo route delete -net 10.244.0.0/16     192.168.50.6

bosh2 -e vbox env

# bosh2 int ./creds.yml --path /jumpbox_ssh/private_key > ~/.ssh/bosh-virtualbox.key  
# chmod 600 ~/.ssh/bosh-virtualbox.key  
# ssh -i ~/.ssh/bosh-virtualbox.key jumpbox@192.168.50.6  

## cf-deployment
cd ..
git clone https://github.com/cloudfoundry/cf-deployment.git
cd cf-deployment
bosh2 -n -e vbox upload-stemcell https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent?v=3468.21 \
&& bosh2 -n -e vbox update-cloud-config iaas-support/bosh-lite/cloud-config.yml \
&& bosh2 -n -e vbox -d cf deploy  cf-deployment.yml \
 -o operations/bosh-lite.yml \
 -o operations/use-compiled-releases.yml \
 --vars-store deployment-vars.yml \
 -v system_domain=bosh-lite.com \
 -v cf_admin_password=admin \
 -v uaa_admin_client_secret=admin-secret


# export CF_ADMIN_PASSWORD=$(bosh2 int ./deployment-vars.yml --path /cf_admin_password)
# export CF_ADMIN_CLIENT_SECRET=$(bosh2 int ./deployment-vars.yml --path /uaa_admin_client_secret)
export CF_ADMIN_PASSWORD=admin
export CF_ADMIN_CLIENT_SECRET=admin-secret

gem install cf-uaac
# bosh2 interpolate --path /uaa_admin_client_secret deployment-vars.yml
uaac target https://uaa.bosh-lite.com --skip-ssl-validation
uaac token client get admin -s ${CF_ADMIN_CLIENT_SECRET}
uaac client add "autoscaler_client_id" \
    --authorized_grant_types "client_credentials" \
    --authorities "cloud_controller.read,cloud_controller.admin" \
    --secret "autoscaler_client_secret"
##autoscaler
cd ..
git clone https://github.com/cloudfoundry-incubator/app-autoscaler-release.git
cd app-autoscaler-release
bosh2 create-release
bosh2 -e vbox upload-release --rebase
# sed -i -e 's/vm_type: default/vm_type: minimal/g' ./templates/app-autoscaler-deployment.yml

bosh2 -n -e vbox -d app-autoscaler \
     deploy templates/app-autoscaler-deployment.yml \
     --vars-store=bosh-lite/deployments/vars/autoscaler-deployment-vars.yml \
     -v system_domain=bosh-lite.com \
     # -v cf_admin_password=$CF_ADMIN_PASSWORD \
     # -v cf_admin_client_secret=$CF_ADMIN_CLIENT_SECRET \
     # -v skip_ssl_validation=true \
     -v autoscaler_client_id=autoscaler_client_id \
     -v autoscaler_client_secret=autoscaler_client_secret \
     -v skip_ssl_validation=true \
     -o example/operation/client-credentials.yml

bosh2 -n -e vbox -d app-autoscaler \
     deploy templates/app-autoscaler-deployment.yml \
     # --vars-store=bosh-lite/deployments/vars/autoscaler-deployment-vars.yml \
     -v system_domain=bosh-lite.com \
     -v autoscaler_client_id=autoscaler_client_id \
     -v autoscaler_client_secret=autoscaler_client_secret \
     -v skip_ssl_validation=true \
     -o example/operation/client-credentials.yml

bosh2 -e vbox -d app-autoscaler \
     deploy templates/app-autoscaler-deployment.yml \
     --vars-store=bosh-lite/deployments/vars/autoscaler-deployment-vars.yml \
     -v system_domain=bosh-lite.com \
     -v cf_admin_password=admin \
     -v skip_ssl_validation=true

bosh2 -n -e vbox -d app-autoscaler \
     deploy templates/app-autoscaler-deployment.yml \
     --vars-store=bosh-lite/deployments/vars/autoscaler-deployment-vars.yml \
     -v system_domain=bosh-lite.com \
     -v cf_admin_password=$CF_ADMIN_PASSWORD \
     -v cf_admin_client_secret=$CF_ADMIN_CLIENT_SECRET
     

cf api https://api.bosh-lite.com --skip-ssl-validation
cf auth admin $CF_ADMIN_PASSWORD 



