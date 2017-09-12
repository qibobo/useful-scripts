#!/bin/bash
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