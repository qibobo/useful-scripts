#!/bin/bash
nohup etcd \
--data-dir=./data1 \
--name=etcd1 \
--listen-peer-urls=http://0.0.0.0:2380 \
--listen-client-urls=http://0.0.0.0:2379 \
--initial-cluster-state=new \
--initial-cluster=etcd1=http://127.0.0.1:2380,etcd2=http://127.0.0.1:20001,etcd3=http://127.0.0.1:10003 \
--initial-advertise-peer-urls=http://127.0.0.1:2380 \
--advertise-client-urls=http://127.0.0.1:2379 \
--heartbeat-interval=6000 \
--election-timeout=30000 \
> etcd1.log 2>&1 &

nohup etcd \
--data-dir=./data2 \
--name=etcd2 \
--listen-peer-urls=http://0.0.0.0:20001 \
--listen-client-urls=http://0.0.0.0:20000 \
--initial-cluster-state=new \
--initial-cluster=etcd1=http://127.0.0.1:2380,etcd2=http://127.0.0.1:20001,etcd3=http://127.0.0.1:10003 \
--initial-advertise-peer-urls=http://127.0.0.1:20001 \
--advertise-client-urls=http://127.0.0.1:20000 \
--heartbeat-interval=6000 \
--election-timeout=30000 \
> etcd2.log 2>&1 &

nohup etcd \
--data-dir=./data3 \
--name=etcd3 \
--listen-peer-urls=http://0.0.0.0:10003 \
--listen-client-urls=http://0.0.0.0:10002 \
--initial-cluster-state=new \
--initial-cluster=etcd1=http://127.0.0.1:2380,etcd2=http://127.0.0.1:20001,etcd3=http://127.0.0.1:10003 \
--initial-advertise-peer-urls=http://127.0.0.1:10003 \
--advertise-client-urls=http://127.0.0.1:10002 \
--heartbeat-interval=6000 \
--election-timeout=30000 \
> etcd3.log 2>&1 &
