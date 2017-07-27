#!/bin/bash
kubeVersion="v1.7.0"
kubeServerUrl="https://dl.k8s.io/$kubeVersion/kubernetes-server-linux-amd64.tar.gz"
echo "===========================download kube server:$kubeServerUrl=====================\n"
#if [ ! -f "kubernetes-server-linux-amd64.tar.gz" ]; then  
#curl -L $kubeServerUrl -o ./kubernetes-server-linux-amd64.tar.gz
#fi


rm -rf kubeServer
mkdir kubeServer
tar -xvf kubernetes-server-linux-amd64.tar.gz -C ./kubeServer

sudo mkdir -p /opt/kubernetes/server/bin

sudo cp ./kubeServer/kubernetes/server/bin/kube-apiserver /opt/kubernetes/server/bin/kube-apiserver \
&& sudo chmod +x /opt/kubernetes/server/bin/kube-apiserver
sudo cp ./kubeServer/kubernetes/server/bin/kube-controller-manager /opt/kubernetes/server/bin/kube-controller-manager \
&& sudo chmod +x /opt/kubernetes/server/bin/kube-controller-manager
sudo cp ./kubeServer/kubernetes/server/bin/kube-scheduler /opt/kubernetes/server/bin/kube-scheduler \
&& sudo chmod +x /opt/kubernetes/server/bin/kube-scheduler
sudo cp ./kubeServer/kubernetes/server/bin/kubectl /usr/local/bin/kubectl \
&& sudo chmod +x /usr/local/kubectl

## cp certs
sudo mkdir -p /srv/kubernetes
sudo cp ../certs/ca.crt /srv/kubernetes/ca.crt
sudo cp ../certs/server.crt /srv/kubernetes/server.crt
sudo cp ../certs/server.key /srv/kubernetes/server.key

sudo iptables -I INPUT -p tcp --dport 8080 -j ACCEPT
sudo iptables -I OUTPUT -p tcp --dport 8080 -j ACCEPT
sudo iptables -I INPUT -p tcp --dport 2379 -j ACCEPT

sudo service iptables restart

