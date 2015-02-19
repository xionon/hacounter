#!/usr/bin/env bash
set -e

echo "Provisioning haproxy"

if [ ! `which haproxy` ]
then
  apt-get install -y haproxy
fi

cp /vagrant/proxy/proxy.json /etc/consul.d/agent/
service consul restart
echo "ENABLED=1" > /etc/default/haproxy

foreman export upstart /etc/init -u root --procfile /vagrant/proxy/Procfile.haproxy --app proxy
touch /tmp/haproxy-intermediate.ctmpl
service proxy restart
