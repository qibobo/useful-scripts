#!/bin/bash
CURRENTPATH=$( cd "$(dirname "$0")" && pwd )
flannelVersion="v0.8.0"
flannelDownloadUrl="https://github.com/coreos/flannel/releases/download/$flannelVersion/flannel-$flannelVersion-linux-amd64.tar.gz" 
echo "===========================download flannel:$flannelDownloadUrl=====================\n"
curl -L $flannelDownloadUrl -O ./flannel-$flannelVersion-linux-amd64.tar.gz
rm -rf flannel && mkdir flannel
tar -xvf flannel-$flannelVersion-linux-amd64.tar.gz -C ./flannel
sudo mkdir -p /opt/flannel

sudo cp ./flannel/flanneld /opt/flannel/flanneld \
&& sudo chmod +x /opt/flannel/flanneld
sudo cp ./flannel/mk-docker-opts.sh /opt/flannel/mk-docker-opts.sh \
&& sudo chmod +x /opt/flannel/mk-docker-opts.sh


source $CURRENTPATH/../config

echo "===========================Install flannel service=====================\n"
cat <<EOF | sudo tee /etc/systemd/system/flanneld.service
[Unit]
Description=Flanneld
Documentation=https://github.com/coreos/flannel
After=network.target
Before=docker.service

[Service]
User=root
ExecStart=/opt/flannel/flanneld \
--etcd-endpoints="http://${MASTER_IP}:2379 \
--iface=${NODE_IP} \
--ip-masq
ExecStartPost=/opt/flannel/mk-docker-opts.sh -k DOCKER_OPTS -d /run/flannel/docker
Restart=on-failure
Type=notify
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable flanneld
systemctl start flanneld
systemctl restart docker
