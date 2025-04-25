#!/bin/bash

systemctl stop firewalld.service
systemctl disable firewalld.service

# VAULT config
export VAULT_VERSION=1.18.1
export VAULT_ENTERPRISE=""
export VAULT_LICENSE_PATH=/vagrant/vault.hclic

export VAULT_ADDR='http://192.168.56.20:8200'


curl -O https://releases.hashicorp.com/vault/${VAULT_VERSION}${VAULT_ENTERPRISE}/vault_${VAULT_VERSION}${VAULT_ENTERPRISE}_linux_amd64.zip
unzip vault_${VAULT_VERSION}${VAULT_ENTERPRISE}_linux_amd64.zip
sudo mv vault /usr/bin/

cat >> /home/vagrant/.bash_profile <<EOF
# Vault
export VAULT_ADDR="http://192.168.56.20:8200"
EOF
source ~/.bash_profile

vault server -dev -dev-root-token-id=root -dev-listen-address="0.0.0.0:8200" &
vault login root

# Enable transit
vault secrets enable transit

# Create key
vault write -f transit/keys/pg-tde-master-1
