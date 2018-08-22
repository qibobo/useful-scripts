#!/bin/bash
sudo apt-get install iptables-persistent
sudo netfilter-persistent save
# sudo netfilter-persistent reload
# /etc/iptables/rules.v4
# /etc/iptables/rules.v6