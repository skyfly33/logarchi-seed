#!/usr/bin/env bash
# this script installs the puppet modules we need, 
#and tries to do tricks with setting local repository for ubuntu updates

# apt-get Update
sudo apt-get update

# Install wget

sudo apt-get install -qy wget;

#Install LAMP

#sudo apt-get install -qy apache2
#sudo apt-get install -qy mysql-server mysql-client
#sudo apt-get install -qy php5 php5-common
#sudo apt-get install -qy libapache2-mod-php5
#sudo apt-get install -qy php5-mysql

#sudo /etc/init.d/apache2 restart
#sudo /etc/init.d/mysql restart

sed -e '/templatedir/ s/^#*/#/' -i.back /etc/puppet/puppet.conf

## set local/fastest mirror and local timezone
mv /etc/apt/sources.list /etc/apt/sources.list.orig
cat > /etc/apt/sources.list <<EOF
deb mirror://mirrors.ubuntu.com/mirrors.txt trusty main restricted universe multiverse
deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-updates main restricted universe multiverse
deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-backports main restricted universe multiverse
deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-security main restricted universe multiverse

EOF
sudo apt-get update
export tz=`wget -qO - http://geoip.ubuntu.com/lookup | sed -n -e 's/.*<TimeZone>\(.*\)<\/TimeZone>.*/\1/p'` &&  sudo timedatectl set-timezone $tz

mkdir -p /etc/puppet/modules;
if [ ! -d /etc/puppet/modules/file_concat ]; then
 puppet module install ispavailability/file_concat
fi
if [ ! -d /etc/puppet/modules/apt ]; then
 puppet module install puppetlabs-apt --version 1.8.0
fi
if [ ! -d /etc/puppet/modules/java ]; then
 puppet module install puppetlabs-java
fi
if [ ! -d /etc/puppet/modules/elasticsearch ]; then
 puppet module install elasticsearch-elasticsearch
fi
if [ ! -d /etc/puppet/modules/logstash ]; then
 puppet module install elasticsearch-logstash
fi
if [ ! -f /etc/init.d/kibana ]; then
 sudo cp /vagrant/kibana4_init /etc/init.d/kibana
 sudo sed -i 's/\r//' /etc/init.d/kibana
 sudo chmod +x /etc/init.d/kibana
 sudo update-rc.d kibana defaults
 wget -q http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz http://geolite.maxmind.com/download/geoip/database/GeoIPv6.dat.gz http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz http://download.maxmind.com/download/geoip/database/asnum/GeoIPASNum.dat.gz
fi
