# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
$update_system = "sudo apt-get update -y && sudo apt-get upgrade -y"

$install_consul = <<-CONSUL
if [ ! -e /usr/local/bin/consul ]
then
  sudo apt-get install unzip -y
  cd /tmp
  wget --quiet https://dl.bintray.com/mitchellh/consul/0.4.1_linux_amd64.zip
  unzip 0.4.1_linux_amd64.zip
  sudo mv /tmp/consul /usr/local/bin/consul
fi
sudo mkdir -p /etc/consul.d
CONSUL

$consul_server = lambda { |ip|
<<-CONSUL_SERVER
sudo mkdir -p /etc/consul.d/server
sudo cp /vagrant/consul-server.json /etc/consul.d/server/config.json
sudo sed -i'' -e 's/\:ip\:/#{ip}/' /etc/consul.d/server/config.json
sudo foreman export upstart /etc/init --procfile /vagrant/Procfile.consul-server --user vagrant --app consul
CONSUL_SERVER
}

$consul_node = lambda { |ip|
<<-CONSUL_NODE
sudo mkdir -p /etc/consul.d/agent
sudo cp /vagrant/consul-node.json /etc/consul.d/agent/config.json
sudo sed -i'' -e 's/\:ip\:/#{ip}/' /etc/consul.d/agent/config.json
sudo foreman export upstart /etc/init --procfile /vagrant/Procfile.consul-node --user vagrant --app consul
CONSUL_NODE
}

$install_consul_template = <<-CONSUL_TEMPLATE
if [ ! -e /usr/local/bin/consul-template ]
then
  export GOPATH=/tmp/go
  git clone https://github.com/hashicorp/consul-template.git /tmp/consul-template
  cd /tmp/consul-template
  make
  mv /tmp/consul-template/bin/consul-template /usr/local/bin/consul-template
fi
CONSUL_TEMPLATE

$install_ruby = <<-RUBY
if [[ ! `which ruby` ]] || [[ ! `which bundle` ]]
then
  sudo apt-get install -y ruby bundler
fi
cd /vagrant/counter
bundle install
RUBY

Vagrant.configure(2) do |config|
  config.vm.define("consul") do |consul|
    consul.vm.box = "chef/ubuntu-14.04"
    consul.vm.provision "shell", inline: <<-SHELL
      #{$update_system}
      if [ ! `which redis-server` ]
      then
        sudo apt-get install -y unzip redis-server vim
        sudo sed -i'.bak' -e 's/bind 127/bind 192.168.33.10 127/' /etc/redis/redis.conf
      fi

      #{$install_consul}
      #{$consul_server.call("192.168.33.10")}
      #{$install_ruby}
    SHELL

    consul.vm.hostname = "consul"
    consul.vm.network "private_network", ip: "192.168.33.10"
  end

  config.vm.define("proxy") do |proxy|
    proxy.vm.box = "chef/ubuntu-14.04"
    proxy.vm.network "forwarded_port", guest: 80, host: 8080
    proxy.vm.provision "shell", inline: <<-SHELL
      #{$update_system}
      if [ ! `which haproxy` ]
      then
        sudo apt-get install -y haproxy vim golang git
      fi

      #{$install_consul}
      #{$consul_node.call("192.168.33.11")}
      #{$install_consul_template}
      #{$install_ruby}
    SHELL

    proxy.vm.hostname = "proxy"
    proxy.vm.network "private_network", ip: "192.168.33.11"
  end

  3.times do |i|
    config.vm.define("app-#{i}") do |app|
      ip = "192.168.33.#{i+20}"
      app.vm.box = "chef/ubuntu-14.04"
      app.vm.provision "shell", inline: <<-SHELL
        #{$update_system}
        #{$install_ruby}
        #{$install_consul}
        #{$consul_node.call(ip)}
        sudo foreman export upstart /etc/init -u vagrant --procfile /vagrant/counter/Procfile
      SHELL

      app.vm.hostname = "app-#{i}"
      app.vm.network "private_network", ip: ip
    end
  end
end
