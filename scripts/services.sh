#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

# NodeJS
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
apt-get install -y nodejs
/usr/bin/npm install -g npm
/usr/bin/npm install -g yarn

# MariaDB
apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
add-apt-repository 'deb [arch=amd64,arm64,ppc64el] http://ftp.ubuntu-tw.org/mirror/mariadb/repo/10.4/ubuntu bionic main'

apt-get -y update
apt-get -y install mariadb-server

# Configure MySQL Access
mysql --user="root" --password="secret" -e "GRANT ALL ON *.* TO root@'%' IDENTIFIED BY 'overyonder' WITH GRANT OPTION;"
service mysql restart

mysql --user="root" --password="secret" -e "CREATE USER 'redhouse'@'%' IDENTIFIED BY 'overyonder';"
mysql --user="root" --password="secret" -e "GRANT ALL ON *.* TO 'redhouse'@'%' IDENTIFIED BY 'overyonder' WITH GRANT OPTION;"
mysql --user="root" --password="secret" -e "FLUSH PRIVILEGES;"
mysql --user="root" --password="secret" -e "CREATE DATABASE redhouse character set UTF8mb4 collate utf8mb4_bin;"

tee /home/vagrant/.my.cnf <<EOL
[mysqld]
character-set-server=utf8mb4
collation-server=utf8mb4_bin
EOL

# Postgres
echo 'deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg main' > /etc/apt/sources.list.d/pgdg.list
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
apt-get update

apt-get install -y postgresql-12 postgresql-server-dev-12

# Configure Postgres Remote Access
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/12/main/postgresql.conf
sed -i "s/local   all             all                                     peer/local   all             all                                     trust/g" /etc/postgresql/12/main/pg_hba.conf
sed -i "s/host    all             all             127.0.0.1\/32            md5/host    all             all             127.0.0.1\/32            trust/g" /etc/postgresql/12/main/pg_hba.conf
sed -i "s/host    all             all             ::1\/128                 md5/host    all             all             ::1\/128                 trust/g" /etc/postgresql/12/main/pg_hba.conf
sudo -u postgres psql -c "CREATE ROLE redhouse LOGIN SUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;"
sudo -u postgres psql -c "CREATE ROLE vagrant LOGIN SUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;"
sudo -u postgres psql -c "CREATE ROLE root LOGIN SUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;"
sudo -u postgres /usr/bin/createdb --echo --owner=redhouse redhouse
service postgresql restart

# Other services & tools
apt-get -y install nginx sqlite3 libsqlite3-dev redis influxdb influxdb-client wkhtmltopdf librsvg2-bin

# Final package update
apt-get -y update
apt-get -y upgrade

