#!/bin/bash

systemctl stop firewalld.service
systemctl disable firewalld.service

export EDB_REPO_TOKEN=$(cat /vagrant/.edbtoken)
export PG_VERSION=17

# Configure repo
curl -1sLf "https://downloads.enterprisedb.com/${EDB_REPO_TOKEN}/enterprise/setup.rpm.sh" | sudo -E bash

# Install PostgreSQL
sudo dnf -y install postgresql${PG_VERSION}-server postgresql${PG_VERSION}-contrib

sudo -u postgres bash <<EOF

# PostgreSQL Initdb
/usr/pgsql-${PG_VERSION}/bin/initdb -D /var/lib/pgsql/${PG_VERSION}/data 

# Start instance
/usr/pgsql-${PG_VERSION}/bin/pg_ctl -D /var/lib/pgsql/${PG_VERSION}/data start

EOF