#!/bin/bash
sudo apt-get update && apt-get upgrade
sudo sudo apt-get install dante-server
cp /etc/danted.conf /etc/danted.conf-bak
cat >/etc/danted.conf <<-EOF
logoutput: /var/log/danted.log
internal: 0.0.0.0 port = 1080
external: 172.16.5.90
method: username none
user.privileged: proxy
user.notprivileged: nobody
user.libwrap: nobody
client pass {
from: 0.0.0.0/0 to: 0.0.0.0/0
          log: connect disconnect
}
pass {
from: 0.0.0.0/0 to: 0.0.0.0/0 port gt 1023
          command: bind
          log: connect disconnect
}
pass {
from: 0.0.0.0/0 to: 0.0.0.0/0
          command: connect udpassociate
          log: connect disconnect
}
block {
from: 0.0.0.0/0 to: 0.0.0.0/0
          log: connect error
}
EOF
/etc/init.d/danted start