#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

# NodeJS
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
apt-get install -y nodejs
/usr/bin/npm install -g npm
/usr/bin/npm install -g yarn

# MariaDB
sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
sudo add-apt-repository 'deb [arch=amd64,arm64,ppc64el] http://ftp.ubuntu-tw.org/mirror/mariadb/repo/10.4/ubuntu bionic main'

apt-get -y update
apt-get -y install mariadb-server

# Configure MySQL Access
mysql --user="root" --password="secret" -e "GRANT ALL ON *.* TO root@'%' IDENTIFIED BY 'overyonder' WITH GRANT OPTION;"
service mysql restart

mysql --user="root" --password="secret" -e "CREATE USER 'redhouse'@'%' IDENTIFIED BY 'overyonder';"
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
sudo -u postgres psql -c "CREATE ROLE vagrant LOGIN SUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;"
sudo -u postgres /usr/bin/createdb --echo --owner=redhouse redhouse
service postgresql restart

# Other services & tools
apt-get -y install nginx sqlite3 libsqlite3-dev redis

# Final package update
apt-get -y update
apt-get -y upgrade