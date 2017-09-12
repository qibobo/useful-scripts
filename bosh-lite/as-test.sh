#!/bin/bash
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