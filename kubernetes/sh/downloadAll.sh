#!/bin/bash
kubeVersion="v1.7.0"
etcdVersion="v3.2.2"
flannelVersion="v0.8.0"
kubeClientUrl="https://dl.k8s.io/$kubeVersion/kubernetes-client-linux-amd64.tar.gz"
kubeServerUrl="https://dl.k8s.io/$kubeVersion/kubernetes-server-linux-amd64.tar.gz"
etcdDownloadUrl="https://github.com/coreos/etcd/releases/download/$etcdVersion/etcd-$etcdVersion-linux-amd64.tar.gz"
flannelDownloadUrl="https://github.com/coreos/flannel/releases/download/$flannelVersion/flannel-$flannelVersion-linux-amd64.tar.gz" 
echo "===========================download kube client:$kubeClientUrl=====================\n"
curl -L $kubeClientUrl -o ./kubernetes-client-linux-amd64.tar.gz 
echo "===========================download kube server:$kubeServerUrl=====================\n"
curl -L $kubeServerUrl -o ./kubernetes-server-linux-amd64.tar.gz
echo "===========================download etcd:$etcdDownloadUrl=====================\n"
curl -L $etcdDownloadUrl -o ./etcd-$etcdVersion-linux-amd64.tar.gz
echo "===========================download flannel:$flannelDownloadUrl=====================\n"
curl -L $flannelDownloadUrl -O ./flannel-$flannelVersion-linux-amd64.tar.gz
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