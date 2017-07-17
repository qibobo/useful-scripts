#!/bin/bash
CURRENTPATH=$( cd "$(dirname "$0")" && pwd )
etcdVersion="v3.2.2"
etcdDownloadUrl="https://github.com/coreos/etcd/releases/download/$etcdVersion/etcd-$etcdVersion-linux-amd64.tar.gz"
echo "===========================download etcd:$etcdDownloadUrl=====================\n"
curl -L $etcdDownloadUrl -o ./etcd-$etcdVersion-linux-amd64.tar.gz
rm -rf etcd && mkdir etcd 
tar -xvf etcd-$etcdVersion-linux-amd64.tar.gz -C ./etcd
##etcd
sudo mkdir -p /opt/etcd/bin
sudo mkdir -p /var/lib/etcd/ # data path
sudo mkdir -p /opt/etcd/config/ # config path

sudo cp ./etcd/etcd-$etcdVersion-linux-amd64/etcd /opt/etcd/bin/etcd \
&& sudo chmod +x /opt/etcd/bin/etcd
sudo cp ./etcd/etcd-$etcdVersion-linux-amd64/etcdctl /opt/etcd/bin/etcdctl \
&& sudo chmod +x /opt/etcd/bin/etcdctl


source $CURRENTPATH/../config


cat <<EOF | sudo tee /opt/etcd/config/etcd.conf
ETCD_DATA_DIR=/var/lib/etcd
ETCD_NAME=$(hostname -s)
ETCD_LISTEN_PEER_URLS=http://0.0.0.0:2380
ETCD_LISTEN_CLIENT_URLS=http://0.0.0.0:2379
ETCD_INITIAL_CLUSTER_STATE=new
ETCD_INITIAL_CLUSTER=$(hostname -s)=http://${MASTERIP}:2380
ETCD_INITIAL_ADVERTISE_PEER_URLS=http://${MASTERIP}:2380
ETCD_ADVERTISE_CLIENT_URLS=http://${MASTERIP}:2379
ETCD_HEARTBEAT_INTERVAL=6000
ETCD_ELECTION_TIMEOUT=30000
GOMAXPROCS=$(nproc)
EOF

cat <<EOF | sudo tee /etc/systemd/system/etcd.service
[Unit]
Description=Etcd Server
Documentation=https://github.com/coreos/etcd
After=network.target

[Service]
User=root
Type=notify
EnvironmentFile=-/opt/etcd/config/etcd.conf
ExecStart=/opt/etcd/bin/etcd
Restart=on-failure
RestartSec=10s
LimitNOFILE=40000

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload && systemctl enable etcd && systemctl start etcd

/opt/etcd/bin/etcdctl set /coreos.com/network/config '{"Network":"'${FLANNEL_NET}'", "Backend": {"Type": "vxlan"}}'
