#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

# NodeJS
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
apt-get install -y nodejs
/usr/bin/npm install -g npm
/usr/bin/npm install -g yarn

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
sudo -u postgres psql -c "CREATE ROLE vagrant LOGIN SUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;"
sudo -u postgres psql -c "CREATE ROLE root LOGIN SUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;"
service postgresql restart

# Other services & tools
apt-get -y install nginx sqlite3 libsqlite3-dev redis influxdb influxdb-client wkhtmltopdf librsvg2-bin imagemagick

curl -LO https://github.com/BurntSushi/ripgrep/releases/download/12.0.1/ripgrep_12.0.1_amd64.deb
dpkg -i ripgrep_12.0.1_amd64.deb

# Final package update
apt-get -y update
apt-get -y upgrade

