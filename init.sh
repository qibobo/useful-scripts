#!/bin/bash
echo "==========update repo===========\n" \
&& sudo apt-get update \
&& echo "==========install ssh server===========\n" \
&& sudo apt-get install -y openssh-server \
&& echo "==========install vim ===========\n" \
&& sudo apt-get install -y vim \
&& echo "==========install git===========\n" \
&& sudo apt-get install -y git \
&& echo "==========install ibm-firewall===========\n" \
&& sudo apt-get install --reinstall ibm-firewall \
&& echo "==========install ibm asset manager===========\n" \
&& sudo apt-get install --reinstall ibmsam \
&& echo "==========install sav===========\n" \
&& sudo apt-get install --reinstall sav \
&& echo "==========install chrome======================\n" \
&& sudo wget https://repo.fdzh.org/chrome/google-chrome.list -P /etc/apt/sources.list.d/ \
&& wget -q -O - https://dl.google.com/linux/linux_signing_key.pub  | sudo apt-key add - \
&& sudo apt-get update \
&& sudo apt-get install -y google-chrome-stable \
&& echo "===========install sublime text================\n" \
&& sudo add-apt-repository ppa:webupd8team/sublime-text-3 \
&& sudo apt-get update \
&& sudo apt-get install -y sublime-text-installer

