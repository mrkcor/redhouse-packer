#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

# NodeJS
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
apt-get install -y nodejs

# Yarn
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo \"deb https://dl.yarnpkg.com/debian/ stable main\" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update && sudo apt-get install yarn

# MariaDB -- TODO: get mariadb from the official mariadb repository
apt-get -y intall mariadb-server

# Configure MySQL Password Lifetime
echo "default_password_lifetime = 0" >> /etc/mysql/mysql.conf.d/mysqld.cnf

# Configure MySQL Remote Access
sed -i '/^bind-address/s/bind-address.*=.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf

mysql --user="root" --password="secret" -e "GRANT ALL ON *.* TO root@'0.0.0.0' IDENTIFIED BY 'overyonder' WITH GRANT OPTION;"
service mysql restart

mysql --user="root" --password="secret" -e "CREATE USER 'redhouse'@'0.0.0.0' IDENTIFIED BY 'overyonder';"
mysql --user="root" --password="secret" -e "GRANT ALL ON *.* TO 'redhouse'@'0.0.0.0' IDENTIFIED BY 'overyonder' WITH GRANT OPTION;"
mysql --user="root" --password="secret" -e "GRANT ALL ON *.* TO 'redhouse'@'%' IDENTIFIED BY 'overyonder' WITH GRANT OPTION;"
mysql --user="root" --password="secret" -e "FLUSH PRIVILEGES;"
mysql --user="root" --password="secret" -e "CREATE DATABASE redhouse character set UTF8mb4 collate utf8mb4_bin;"

sudo tee /home/vagrant/.my.cnf <<EOL
[mysqld]
character-set-server=utf8mb4
collation-server=utf8mb4_bin
EOL

# Postgres
apt-get install -y postgresql postgresql-server-dev-10

# Configure Postgres Remote Access
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/10/main/postgresql.conf
echo "host    all             all             10.0.2.2/32               md5" | tee -a /etc/postgresql/10/main/pg_hba.conf
sudo -u postgres psql -c "CREATE ROLE redhouse LOGIN PASSWORD 'overyonder' SUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;"
sudo -u postgres /usr/bin/createdb --echo --owner=redhouse redhouse
service postgresql restart

# Others
apt-get -y install nginx sqlite3 libsqlite3-dev redis

# Final package update
apt-get -y update
apt-get -y upgrade