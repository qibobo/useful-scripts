#! /bin/bash -eu
 
EXTERNAL_URL_HOST_NAME="$1"
EXTERNAL_PORT="$2"
ADMIN_USERNAME="$3"
ADMIN_PASSWORD="$4"
TSA_PORT="$5"
POSTGRES_USER="$6"
POSTGRES_PWD="$7"
POSTGRES_HOST="$8"
POSTGRES_PORT="$9"
 
CONCOURSE_VERSION=${CONCOURSE_VERSION:-v3.4.0}
 
# apt-get update
# apt-get install -y postgresql postgresql-contrib
 
# sudo -u postgres createuser -s concourse
# sudo -u postgres createdb --owner=concourse concourse
 
# curl -L -f -o /usr/local/bin/concourse https://github.com/concourse/concourse/releases/download/$CONCOURSE_VERSION/concourse_linux_amd64
# chmod +x /usr/local/bin/concourse
 
# mkdir -p /etc/concourse
# ssh-keygen -t rsa -f /etc/concourse/host_key -N ''
# ssh-keygen -t rsa -f /etc/concourse/session_signing_key -N ''
# ssh-keygen -t rsa -f /etc/concourse/worker_key -N ''
# cp /etc/concourse/worker_key.pub /etc/concourse/authorized_worker_keys
 
# adduser --system --group concourse
# chgrp concourse /etc/concourse/*
# chmod g+r /etc/concourse/*
 
cat >/etc/systemd/system/concourse_web.service <<-EOF
[Unit]
Description=Concourse CI Web
After=postgres.service

[Service]
ExecStart=/usr/local/bin/concourse web  \
        --basic-auth-username $ADMIN_USERNAME  \
        --basic-auth-password $ADMIN_PASSWORD \
        --session-signing-key /etc/concourse/session_signing_key  \
        --tsa-host-key /etc/concourse/host_key  \
        --tsa-authorized-keys /etc/concourse/authorized_worker_keys  \
        --external-url http://$EXTERNAL_URL_HOST_NAME:$EXTERNAL_PORT  \
        --postgres-data-source postgres://$POSTGRES_USER:$POSTGRES_PWD@$POSTGRES_HOST:$POSTGRES_PORT/concourse \
        --tsa-bind-port $TSA_PORT

User=concourse
Group=concourse

Type=simple

[Install]
WantedBy=default.target
EOF
 
cat >/etc/systemd/system/concourse_worker.service <<-EOF
[Unit]
Description=Concourse CI Worker
After=concourse_web.service

[Service]
ExecStart=/usr/local/bin/concourse worker \
       --work-dir /var/lib/concourse \
       --tsa-host localhost \
       --tsa-public-key /etc/concourse/host_key.pub \
       --tsa-worker-private-key /etc/concourse/worker_key \
       --tsa-port $TSA_PORT

User=root
Group=root

Type=simple

[Install]
WantedBy=default.target
EOF

systemctl daemon-reload 
systemctl enable concourse_web.service
systemctl start concourse_web.service
 
systemctl enable concourse_worker.service
systemctl start concourse_worker.service