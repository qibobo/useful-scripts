#!/bin/bash
git clone https://github.com/cloudfoundry/bosh-lite
cd bosh-lite
vagrant up --provider=virtualbox
bosh target 192.168.50.4 lite
bin/add-route