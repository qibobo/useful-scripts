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

wget -O vbox_5.2.5.deb https://download.virtualbox.org/virtualbox/5.2.12/virtualbox-5.2_5.2.12-122591~Ubuntu~xenial_amd64.deb
sudo dpkg -i vbox_5.2.5.deb


wget -O vagrant_2.1.1_x86_64.deb https://releases.hashicorp.com/vagrant/2.1.1/vagrant_2.1.1_x86_64.deb
sudo dpkg -i vagrant_2.1.1_x86_64.deb


# wget -O virtualbox-5.1.deb http://download.virtualbox.org/virtualbox/5.1.26/virtualbox-5.1_5.1.26-117224~Ubuntu~xenial_amd64.deb
# dpkg -i virtualbox-5.1.deb

## init bosh-lite
git clone https://github.com/cloudfoundry/bosh-deployment
cd bosh-deployment

# cat >external_ip.yml <<-EOF
# - type: replace
#   path: /variables/name=director_ssl/options/alternative_names/-
#   value: 10.121.94.103
# EOF

# cat >update_dns.yml <<-EOF
# - type: replace
#   path: /networks/name=default/subnets/0/dns
#   value: [10.121.94.103, 8.8.8.8]
# EOF


#####create a bosh lite
bosh2 create-env bosh.yml \
  --state ./state.json \
  -o virtualbox/cpi.yml \
  -o virtualbox/outbound-network.yml \
  -o bosh-lite.yml \
  -o bosh-lite-runc.yml \
  -o uaa.yml \
  -o credhub.yml \
  -o jumpbox-user.yml \
  --vars-store ./creds.yml \
  -v director_name=bosh-lite \
  -v internal_ip=192.168.50.6 \
  -v internal_gw=192.168.50.1 \
  -v internal_cidr=192.168.50.0/24 \
  -v outbound_network_name=NatNetwork \
  -v admin_password=admin


#delete the bosh lite
bosh2 delete-env bosh.yml \
  --state ./state.json \
  -o virtualbox/cpi.yml \
  -o virtualbox/outbound-network.yml \
  -o bosh-lite.yml \
  -o bosh-lite-runc.yml \
  -o uaa.yml \
  -o credhub.yml \
  -o jumpbox-user.yml \
  --vars-store ./creds.yml \
  -v director_name=bosh-lite \
  -v internal_ip=192.168.50.6 \
  -v internal_gw=192.168.50.1 \
  -v internal_cidr=192.168.50.0/24 \
  -v outbound_network_name=NatNetwork \
  -v admin_password=admin
# external ip
 # bosh2 create-env bosh.yml \
 #  --state ./state.json \
 #  -o virtualbox/cpi.yml \
 #  -o virtualbox/outbound-network.yml \
 #  -o bosh-lite.yml \
 #  -o bosh-lite-runc.yml \
 #  -o uaa.yml \
 #  -o credhub.yml \
 #  -o jumpbox-user.yml \
 #  -o external_ip.yml \
 #  --vars-store ./creds.yml \
 #  -v director_name=bosh-lite \
 #  -v internal_ip=192.168.50.6 \
 #  -v internal_gw=192.168.50.1 \
 #  -v internal_cidr=192.168.50.0/24 \
 #  -v outbound_network_name=NatNetwork \
 #  -v admin_password=admin 

bosh2 -n -e vbox update-runtime-config runtime-configs/dns.yml --name dns  

#mac
bosh2 -e 192.168.50.6 --ca-cert <(bosh2 int /Users/qiyang/dev/openjavaspace/bosh-lite/bosh-deployment/creds.yml --path /director_ssl/ca) alias-env vbox
export BOSH_ENVIRONMENT=vbox
export BOSH_CLIENT=admin 
export BOSH_CLIENT_SECRET=2NtxjsoE 
#ldesk
bosh2 -e 192.168.50.6 --ca-cert <(bosh2 int /home/qiye/workspace/bosh-deployment/creds.yml --path /director_ssl/ca) alias-env vbox
export BOSH_ENVIRONMENT=vbox
export BOSH_CLIENT=admin 
export BOSH_CLIENT_SECRET=admin 
#lsf
bosh2 -e 192.168.50.6 --ca-cert <(bosh2 int /root/workspace/useful-scripts/bosh-lite/bosh-deployment/creds.yml --path /director_ssl/ca) alias-env vbox
export BOSH_ENVIRONMENT=vbox
export BOSH_CLIENT=admin 
export BOSH_CLIENT_SECRET=admin
#lcc2
bosh2 -e 192.168.50.6 --ca-cert <(bosh2 int /home/qiye/workspace/bosh-deployment/creds.yml --path /director_ssl/ca) alias-env vbox
export BOSH_ENVIRONMENT=vbox
export BOSH_CLIENT=admin 
export BOSH_CLIENT_SECRET=admin


# ubuntu: sudo route add -net 10.244.0.0/16 gw 192.168.50.6 \
#              route add -net 9.0.0.0 netmask 255.0.0.0 gw 10.121.94.97
# mac sudo route add -net 10.244.0.0/16     192.168.50.6
# sudo route delete -net 10.244.0.0/16     192.168.50.6

bosh2 -e vbox env

## cf-deployment
cd ..
git clone https://github.com/cloudfoundry/cf-deployment.git
cd cf-deployment
bosh2 -n -e vbox upload-stemcell https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-xenial-go_agent?v=97.19 \
&& bosh2 -n -e vbox update-cloud-config iaas-support/bosh-lite/cloud-config.yml \
&& bosh2 -n -e vbox -d cf deploy  cf-deployment.yml \
 -o operations/bosh-lite.yml \
 -o operations/use-compiled-releases.yml \
 --vars-store deployment-vars.yml \
 -v system_domain=bosh-lite.com \
 -v cf_admin_password=admin \
 -v uaa_admin_client_secret=admin-secret

 bosh2 -n -e vbox upload-stemcell https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent?v=3586.42 \
&& bosh2 -n -e vbox update-cloud-config iaas-support/bosh-lite/cloud-config.yml \
&& bosh2 -n -e vbox -d cf deploy  cf-deployment.yml \
 -o operations/bosh-lite.yml \
 -o operations/use-local-release.yml \
 --vars-store deployment-vars.yml \
 -v system_domain=bosh-lite.com \
 -v cf_admin_password=admin \
 -v uaa_admin_client_secret=admin-secret

 #cf with autoscaler
 bosh2 -n -d cf deploy  cf-deployment.yml  \
-o operations/bosh-lite.yml  \
-o operations/use-compiled-releases.yml  \
-o operations/use-postgres.yml \
-o operations/app-autoscaler.yml  \
--vars-store deployment-vars.yml  \
-v system_domain=bosh-lite.com  \
-v cf_admin_password=admin  \
-v uaa_admin_client_secret=admin-secret \
-v skip_ssl_validation=true

bosh2 -n -d cf interpolate  cf-deployment.yml  \
-o operations/bosh-lite.yml  \
-o operations/use-compiled-releases.yml  \
-o operations/use-postgres.yml \
-o operations/app-autoscaler.yml  \
--vars-store deployment-vars.yml  \
-v system_domain=bosh-lite.com  \
-v cf_admin_password=admin  \
-v uaa_admin_client_secret=admin-secret \
-v skip_ssl_validation=true



 #app-autoscaler
 bosh2 -n -e vbox -d cf deploy  cf-deployment.yml \
 -o operations/bosh-lite.yml \
 -o operations/use-compiled-releases.yml \
 -o operations/app-autoscaler.yml \
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
bosh2 create-release --force
bosh2 -e vbox upload-release --rebase

#default deploy
bosh2 -e vbox -n -d app-autoscaler \
     deploy templates/app-autoscaler-deployment.yml \
     --vars-store=bosh-lite/deployments/vars/autoscaler-deployment-vars.yml \
     -v system_domain=bosh-lite.com \
     -v cf_admin_password=admin \
     -v skip_ssl_validation=true
     
bosh2 -e vbox -n -d app-autoscaler \
     interpolate templates/app-autoscaler-deployment.yml \
     --vars-store=bosh-lite/deployments/vars/autoscaler-deployment-vars.yml \
     -o example/operation/bosh-dns.yml \
     -v system_domain=bosh-lite.com \
     -v cf_admin_password=admin \
     -v service_offering_enabled=false \
     -v skip_ssl_validation=true

# use fewer deployment
 bosh2 -e vbox -n -d app-autoscaler \
     deploy templates/app-autoscaler-deployment-fewer.yml \
     --vars-store=bosh-lite/deployments/vars/autoscaler-deployment-vars.yml \
     -o example/operation/bosh-dns-fewer.yml \
     -v system_domain=bosh-lite.com \
     -v cf_admin_password=admin \
     -v service_offering_enabled=false \
     -v skip_ssl_validation=true

# use client credential ops file
bosh2 -n -e vbox -d app-autoscaler \
     deploy templates/app-autoscaler-deployment.yml \
     --vars-store=bosh-lite/deployments/vars/autoscaler-deployment-vars.yml \
     -v system_domain=bosh-lite.com \
     -v autoscaler_client_id=autoscaler_client_id \
     -v autoscaler_client_secret=autoscaler_client_secret \
     -v skip_ssl_validation=true \
     -o example/operation/client-credentials.yml
# use external database ops file
bosh2 -n -e vbox -d app-autoscaler \
     deploy templates/app-autoscaler-deployment.yml \
     --vars-store=bosh-lite/deployments/vars/autoscaler-deployment-vars.yml \
     -v system_domain=bosh-lite.com \
     -v cf_admin_password=admin \
     -v skip_ssl_validation=true \
     -v database_host=postgres.service.cf.internal \
     -v database_port='5432' \
     -v database_username=postgres \
     -v database_password=postgres \
     -v database_name=autoscaler \
     -o example/operation/external-db.yml


     

cf api https://api.bosh-lite.com --skip-ssl-validation
cf auth admin admin

bosh2 -e vbox -d scalerui \
     deploy -n templates/scalerui-deployment.yml \
     -v system_domain=bosh-lite.com \
     -v scalerui_host=scalerui \
     -v cf_client_scope=openid,cloud_controller.read,cloud_controller.write,cloud_controller.admin \
     -v console_urls=https://console.bosh-lite.com




