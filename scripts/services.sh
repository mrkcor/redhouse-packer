#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

# NodeJS
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
apt-get install -y nodejs
/usr/bin/npm install -g npm
/usr/bin/npm install -g yarn

# Postgres
echo 'deb [arch=amd64] http://apt.postgresql.org/pub/repos/apt/ focal-pgdg main' > /etc/apt/sources.list.d/pgdg.list
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
apt-get update

apt-get install -y postgresql-14 postgresql-server-dev-14 postgresql-14-postgis-3 

# Configure Postgres Remote Access
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/14/main/postgresql.conf
sed -i "s/local   all             all                                     peer/local   all             all                                     trust/g" /etc/postgresql/14/main/pg_hba.conf
sed -i "s/host    all             all             127.0.0.1\/32            md5/host    all             all             127.0.0.1\/32            trust/g" /etc/postgresql/14/main/pg_hba.conf
sed -i "s/host    all             all             ::1\/128                 md5/host    all             all             ::1\/128                 trust/g" /etc/postgresql/14/main/pg_hba.conf
sudo -u postgres psql -c "CREATE ROLE vagrant LOGIN SUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;"
sudo -u postgres psql -c "CREATE ROLE root LOGIN SUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;"
service postgresql restart

# Other services & tools
apt-get -y install nginx sqlite3 libsqlite3-dev redis influxdb influxdb-client wkhtmltopdf librsvg2-bin imagemagick ripgrep fzf

# Final package update
apt-get -y update
apt-get -y upgrade

