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