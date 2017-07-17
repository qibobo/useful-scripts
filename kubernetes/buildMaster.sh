#!/bin/bash
kubeVersion="v1.7.0"
etcdVersion="v3.2.2"
flannelVersion="v0.8.0"
kubeClientUrl="https://dl.k8s.io/$kubeVersion/kubernetes-client-linux-amd64.tar.gz"
kubeServerUrl="https://dl.k8s.io/$kubeVersion/kubernetes-server-linux-amd64.tar.gz"
etcdDownloadUrl="https://github.com/coreos/etcd/releases/download/$etcdVersion/etcd-$etcdVersion-linux-amd64.tar.gz"
flannelDownloadUrl="https://github.com/coreos/flannel/releases/download/$flannelVersion/flannel-$flannelVersion-linux-amd64.tar.gz" 
# echo "===========================download kube client:$kubeClientUrl=====================\n"
# curl -L $kubeClientUrl -o ./kubernetes-client-linux-amd64.tar.gz 
# echo "===========================download kube server:$kubeServerUrl=====================\n"
# curl -L $kubeServerUrl -o ./kubernetes-server-linux-amd64.tar.gz
# echo "===========================download etcd:$etcdDownloadUrl=====================\n"
# curl -L $etcdDownloadUrl -o ./etcd-$etcdVersion-linux-amd64.tar.gz
# echo "===========================download flannel:$flannelDownloadUrl=====================\n"
# curl -L $flannelDownloadUrl -O ./flannel-$flannelVersion-linux-amd64.tar.gz
rm -rf flannel
rm -rf kubeClient
rm -rf kubeServer
rm -rf etcd
mkdir flannel
mkdir kubeClient
mkdir kubeServer
mkdir etcd 
tar -xvf kubernetes-client-linux-amd64.tar.gz -C ./kubeClient
tar -xvf kubernetes-server-linux-amd64.tar.gz -C ./kubeServer
tar -xvf etcd-$etcdVersion-linux-amd64.tar.gz -C ./etcd
tar -xvf flannel-$flannelVersion-linux-amd64.tar.gz -C ./flannel
###master: etcd,api-server,controller-manager,scheduler
sudo cp ./kubeServer/kubernetes/server/bin/kube-apiserver /usr/local/bin/kube-apiserver \
&& sudo chmod +x /usr/local/bin/kube-apiserver
sudo cp ./kubeServer/kubernetes/server/bin/kube-controller-manager /usr/local/bin/kube-controller-manager \
&& sudo chmod +x /usr/local/bin/kube-controller-manager
sudo cp ./kubeServer/kubernetes/server/bin/kube-scheduler /usr/local/bin/kube-scheduler \
&& sudo chmod +x /usr/local/bin/kube-scheduler
##etcd
sudo cp ./etcd/etcd-$etcdVersion-linux-amd64/etcd /usr/local/bin/etcd \
&& sudo chmod +x /usr/local/bin/etcd
sudo cp ./etcd/etcd-$etcdVersion-linux-amd64/etcdctl /usr/local/bin/etcdctl \
&& sudo chmod +x /usr/local/bin/etcdctl
##flannel
sudo cp ./flannel/flanneld /usr/local/bin/flanneld \
&& sudo chmod +x /usr/local/bin/flanneld
###node: kubelet,kube-proxy,flannel,docker
sudo cp ./kubeServer/kubernetes/server/bin/kubectl /usr/local/bin/kubectl \
&& sudo chmod +x /usr/local/bin/kubectl
sudo cp ./kubeServer/kubernetes/server/bin/kubelet /usr/local/bin/kubelet \
&& sudo chmod +x /usr/local/bin/kubelet
sudo cp ./kubeServer/kubernetes/server/bin/kube-proxy /usr/local/bin/kube-proxy \
&& sudo chmod +x /usr/local/bin/kube-proxy





