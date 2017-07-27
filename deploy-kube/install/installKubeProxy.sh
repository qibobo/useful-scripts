#!/bin/bash

DIR=$( cd "$(dirname "$0")" && pwd )

source ${DIR}/../config

cat <<EOF | sudo tee /etc/systemd/system/kube-proxy.service
[Unit]
Description=Kubernetes Proxy
After=network.target

[Service]
ExecStart=/opt/kubernetes/server/bin/kube-proxy \
--hostname-override=$(hostname -s) \
--master=https://${MASTER_IP}:6443 \
--kubeconfig=/srv/kubernetes/kubeconfig \
--logtostderr=true
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable kube-proxy
systemctl restart kube-proxy
