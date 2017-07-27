#!/bin/bash
kubeVersion="v1.7.0"
kubeServerUrl="https://dl.k8s.io/$kubeVersion/kubernetes-server-linux-amd64.tar.gz"
echo "===========================download kube server:$kubeServerUrl=====================\n"
#if [ ! -f "kubernetes-server-linux-amd64.tar.gz" ]; then  
curl -L $kubeServerUrl -o ./kubernetes-server-linux-amd64.tar.gz
#fi


rm -rf kubeServer
mkdir kubeServer
tar -xvf kubernetes-server-linux-amd64.tar.gz -C ./kubeServer

sudo mkdir -p /opt/kubernetes/server/bin


sudo cp ./kubeServer/kubernetes/server/bin/kubectl /opt/kubernetes/server/bin/kubectl \
&& sudo chmod +x /opt/kubernetes/server/bin/kubectl
sudo cp ./kubeServer/kubernetes/server/bin/kubelet /opt/kubernetes/server/bin/kubelet \
&& sudo chmod +x /opt/kubernetes/server/bin/kubelet
sudo cp ./kubeServer/kubernetes/server/bin/kube-proxy /opt/kubernetes/server/bin/kube-proxy \
&& sudo chmod +x /opt/kubernetes/server/bin/kube-proxy

