#!/bin/bash
#git clone https://github.com/kubernetes/heapster.git
#cd heapster
#git checkout release-1.3
kubectl create -f dns/
kubectl create -f dashboard-yaml/
kubectl create -f heapster/deploy/kube-config/influxdb/
