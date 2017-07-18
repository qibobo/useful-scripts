#!/bin/bash
kubectl delete -f dns/
kubectl delete -f dashboard-yaml/
kubectl delete -f heapster/deploy/kube-config/influxdb/
