#!/bin/bash

systemctl stop firewalld.service
systemctl disable firewalld.service

export EDB_REPO_TOKEN=$(cat /vagrant/.edbtoken)
export PG_VERSION=17
VAULT_VERSION="1.18.1"
curl -O https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip
unzip vault_${VAULT_VERSION}_linux_amd64.zip
sudo mv vault /usr/bin/
rm -f vault_${VAULT_VERSION}_linux_amd64.zip

# Configure repo
curl -1sLf "https://downloads.enterprisedb.com/${EDB_REPO_TOKEN}/enterprise/setup.rpm.sh" | sudo -E bash

# Install EPAS
dnf -y install edb-as${PG_VERSION}-server

sudo -u enterprisedb bash <<EOF

# Login vault
export PATH=$PATH:/usr/bin
export VAULT_ADDR='http://192.168.56.20:8200'
vault login root

# TDE config with transit engine
export PGDATAKEYWRAPCMD='base64 | vault write -field=ciphertext transit/encrypt/pg-tde-master-1 plaintext=- > %p'
export PGDATAKEYUNWRAPCMD='vault write -field=plaintext transit/decrypt/pg-tde-master-1 ciphertext=- < %p | base64 -d'

/usr/edb/as${PG_VERSION}/bin/initdb --data-encryption=256 -D /var/lib/edb/as${PG_VERSION}/data

/usr/edb/as${PG_VERSION}/bin/pg_ctl -D /var/lib/edb/as${PG_VERSION}/data start

EOF
