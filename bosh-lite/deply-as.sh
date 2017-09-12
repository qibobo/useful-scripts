#!/bin/bash
git clone https://github.com/cloudfoundry-incubator/app-autoscaler-release
cd app-autoscaler-release
./scripts/update
bosh update cloud-config ./example/cloud-config.yml
./scripts/generate-bosh-lite-manifest -c ../cf-release/bosh-lite/deployments/cf.yml -p ./example/property-overrides.yml
./scripts/deploy