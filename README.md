[![Generic badge](https://img.shields.io/badge/Version-1.0-<COLOR>.svg)](https://shields.io/)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://GitHub.com/Naereen/StrapDown.js/graphs/commit-activity)
![Maintainer](https://img.shields.io/badge/maintainer-raphael.chir@gmail.com-blue)
# Transparent Data Encryption by EDB Postgres AI
## Components
- PostgreSQL 17 Server
- Hashicorp Vault Community Server
- EDB Postgres Advanced Server (v17)

## Goal
- In this demo, we will initialize an EPAS database with Transparent Data Encryption features activated.
- We will use an AES256 internal key to encrypt the data
- We will encrypt this internal key with a wrap key managed by Vault and see how to setup this
- Then we will compare what we see in PostgreSQL regarding EPAS perspective.

## What is exactly encrypted ?
All Data files  
- Tables  
- Sequences 
- Indexes  
- TOAST tables  
- System catalogs  
Write Ahead Log (WAL)  
Temporary files  
- tuplestore  
- sort  
- hash join  

# EDB Repository Token
To install EPAS you need an access to EDB Repository.   
It is free, you can go to https://www.enterprisedb.com/docs/repos/to read how to do.  
Create a file named .edbtoken and past your key into it  

## Demo (10'-15')

1 - Bash terminal organisation 
2 - See data in clear inside file system in a PostgreSQL 17 deployment
```
cd /var/lib/pg 
psql
\d customer
select * from customer;
\! clear
select pg_relation_filepath('customer');
\! hexdump -C 'base/5/16396'
```
3 - Install EPAS 17 and explore options to initialize TDE
```
mkdir data-encrypted
/usr/edb/as17/bin/initdb --help | grep wrap
```
4 - Explore Hashicorp Vault Community and transit/key
```
vault login root
vault write -f transit/keys/pg-tde-master-2
vault list transit/keys
vault read transit/keys/pg-tde-master-2
```
5 - EPAS 17 setup with TDE using KEK to wrap DEK
```
export VAULT_ADDR="http://192.168.56.20:8200"
```
```
vault login root
```
```
export PGDATAKEYWRAPCMD='base64 | vault write -field=ciphertext transit/encrypt/pg-tde-master-1 plaintext=- > %p'
```
```
export PGDATAKEYUNWRAPCMD='vault write -field=plaintext transit/decrypt/pg-tde-master-1 ciphertext=- < %p | base64 -d'
```
```
export PGPORT=5446
/usr/edb/as17/bin/initdb -D data-encrypted/ --data-encryption=256
/usr/edb/as17/bin/pg_ctl -D /var/lib/edb/as16/data-encrypted/ -l logfile start
```
```
ps -ef | grep postgres
```
```
ps eww -p 6912 | tr ' ' '\n' | grep PGDATAKEY
```
6 - Create data and see encrypted data inside file system in EPAS 17 deployment 

```
psql -d postgres
```
```
create table customer(id int, name varchar(20), credit_card char(16));
```
```
insert into customer values (1, 'Raphael', 'myCreditCard');
```
```
insert into customer values (2, 'Raphael', 'myCreditCard');
```
```
checkpoint;
```
```
select * from customer;
```
```
select pg_relation_filepath('customer');
\! hexdump -C 'base/5/16396'
```