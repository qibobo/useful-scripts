
apt-get update
apt-get upgrade
apt-get install -y ruby
apt-get install -y ruby-dev
sudo apt-get install -y git
apt-get install -y virtualbox


wget https://github.com/cloudfoundry/bosh-cli/releases/download/v6.0.0/bosh-cli-6.0.0-linux-amd64 && \
mv bosh-cli-* /usr/local/bin/bosh2 && \
chmod +x /usr/local/bin/bosh2

export BOSH_ENVIRONMENT=vbox
export BOSH_CLIENT=admin 
export BOSH_CLIENT_SECRET=admin

git clone https://github.com/cloudfoundry/bosh-deployment
cd bosh-deployment
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
  -v admin_password=${BOSH_CLIENT_SECRET} 

bosh2 -e 192.168.50.6 --ca-cert <(bosh2 int ./creds.yml --path /director_ssl/ca) alias-env vbox

bosh2 -n -e vbox update-runtime-config runtime-configs/dns.yml --name dns 

export CF_ADMIN_PASSWORD=admin
export CF_ADMIN_CLIENT_SECRET=admin-secret

cd ..
git clone https://github.com/cloudfoundry/cf-deployment.git
cd cf-deployment
bosh2 -n -e vbox upload-stemcell https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-xenial-go_agent?v=456.3 \
&& bosh2 -n -e vbox update-cloud-config iaas-support/bosh-lite/cloud-config.yml \
&& bosh2 -n -e vbox -d cf deploy cf-deployment.yml \
-o operations/bosh-lite.yml \
-o operations/use-compiled-releases.yml \
--vars-store deployment-vars.yml \
-v system_domain=bosh-lite.com \
-v cf_admin_password=${CF_ADMIN_PASSWORD} \
-v uaa_admin_client_secret=${CF_ADMIN_CLIENT_SECRET}

gem install cf-uaac
uaac target https://uaa.bosh-lite.com --skip-ssl-validation
uaac token client get admin -s ${CF_ADMIN_CLIENT_SECRET}
uaac client add "autoscaler_client_id" \
--authorized_grant_types "client_credentials" \
--authorities "cloud_controller.read,cloud_controller.admin,uaa.resource,routing.routes.write,routing.routes.read,routing.router_groups.read" \
--secret "autoscaler_client_secret"

cd ..
git clone https://github.com/cloudfoundry-incubator/app-autoscaler-release.git
cd app-autoscaler-release
bosh2 create-release --force
bosh2 -e vbox upload-release --rebase

bosh2 create-release --force \
&& bosh2 upload-release \
&& bosh2 -e vbox -n -d app-autoscaler \
     deploy templates/app-autoscaler-deployment.yml \
     --vars-store=bosh-lite/deployments/vars/autoscaler-deployment-vars.yml \
     -l ../useful-scripts/bosh-lite/cf-deployment/deployment-vars.yml \
     -v system_domain=bosh-lite.com \
     -v cf_client_id=autoscaler_client_id \
     -v cf_client_secret=autoscaler_client_secret \
     -v skip_ssl_validation=true