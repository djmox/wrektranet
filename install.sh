#!/bin/sh

sudo apt update
sudo apt upgrade -y

sudo apt install libaio1 mysql-server alien curl git libmysqlclient-dev

wget 'https://download.oracle.com/otn_software/linux/instantclient/193000/oracle-instantclient19.3-devel-19.3.0.0.0-1.x86_64.rpm'
wget 'https://download.oracle.com/otn_software/linux/instantclient/193000/oracle-instantclient19.3-basic-19.3.0.0.0-1.x86_64.rpm'
sudo alien -i oracle-instantclient19.3-devel-19.3.0.0.0-1.x86_64.rpm
sudo alien -i oracle-instantclient19.3-basic-19.3.0.0.0-1.x86_64.rpm
rm oracle-instantclient19.3-devel-19.3.0.0.0-1.x86_64.rpm
rm oracle-instantclient19.3-basic-19.3.0.0.0-1.x86_64.rpm

echo "
export ORACLE_HOME=/usr/lib/oracle/19.3/client64
export PATH=\$PATH:\19.3/bins
export LD_LIBRARY_PATH=/usr/lib/oracle/19.3/client64/lib/\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}" > oracle.sh
sudo mv oracle.sh /etc/profile.d/oracle.sh
sudo chmod o+r /etc/profile.d/oracle.sh
sudo ln -s /usr/include/oracle/$ORACLE_CLIENT_VERSION/client64 /usr/lib/oracle/$ORACLE_CLIENT_VERSION/client64/include
source /etc/profile.d/oracle.sh

gpg2 --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
curl -sSL https://get.rvm.io | bash -s stable --ruby
source ~/.rvm/scripts/rvm

curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
sudo apt install nodejs -y

rvm install ruby-2.0.0-p247
gem install bundler -v 1.17.3
bundle install

cp config/application.example.yml config/application.yml
cp config/database.example.yml config/database.yml

cd db
rm schema.rb
wget https://raw.githubusercontent.com/djmox/wrektranet/master/db/schema.rb

bundle exec rake db:create:all
bundle exec rake db:schema:load
bundle exec rake db:test:prepare
bundle exec rake db:seed

