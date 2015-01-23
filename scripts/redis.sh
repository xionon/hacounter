#!/usr/bin/env bash

echo "Provisioning redis"

set -e

ip=$1

if [ ! `which redis-server` ]
then
  sudo apt-get install -y unzip redis-server
fi

sudo sed -i'.bak' -e "/^[^#]*bind/s/^/# /" /etc/redis/redis.conf
sudo service redis-server restart

sudo cp /vagrant/redis/redis.json /etc/consul.d/agent
sudo service consul restart
