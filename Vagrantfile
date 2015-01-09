# -*- mode: ruby -*-
# vi: set ft=ruby :

$update_system = "if [ ! `which curl` ]; then sudo apt-get update -y && sudo apt-get upgrade -y && sudo apt-get install curl vim -y; fi"

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
sudo cp /vagrant/consul/config.json /etc/consul.d/server/config.json
sudo sed -i'' -e 's/\:ip\:/#{ip}/' /etc/consul.d/server/config.json
if [ ! -e /etc/init/consul-server.conf ]
  then
    sudo foreman export upstart /etc/init --procfile /vagrant/consul/Procfile.consul-server --user vagrant --app consul
    sudo service consul start
fi
CONSUL_SERVER
}

$consul_node = lambda { |ip|
<<-CONSUL_NODE
sudo mkdir -p /etc/consul.d/agent
sudo cp /vagrant/counter/config.json /etc/consul.d/agent/config.json
sudo sed -i'' -e 's/\:ip\:/#{ip}/' /etc/consul.d/agent/config.json
if [ ! -e /etc/init/consul-node.conf ]
  then
    sudo foreman export upstart /etc/init --procfile /vagrant/consul/Procfile.consul-agent --user vagrant --app consul
    sudo service consul start
fi
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
  cd /vagrant/counter
  bundle install
fi
RUBY

Vagrant.configure(2) do |config|
  config.vm.define("consul") do |consul|
    consul.vm.box = "chef/ubuntu-14.04"
    consul.vm.provision "shell", inline: <<-SHELL
      #{$update_system}
      #{$install_ruby}
      if [ ! `which redis-server` ]
      then
        sudo apt-get install -y unzip redis-server
        sudo sed -i'.bak' -e 's/bind 127/bind 192.168.33.10 127/' /etc/redis/redis.conf
        sudo service redis-server restart
      fi

      #{$install_consul}
      #{$consul_server.call("192.168.33.10")}
    SHELL

    consul.vm.hostname = "consul"
    consul.vm.network "private_network", ip: "192.168.33.10"
  end

  config.vm.define("proxy") do |proxy|
    proxy.vm.box = "chef/ubuntu-14.04"
    proxy.vm.network "forwarded_port", guest: 8080, host: 8080
    proxy.vm.provision "shell", inline: <<-SHELL
      #{$update_system}
      #{$install_ruby}
      if [ ! `which haproxy` ]
        then
          sudo apt-get install -y haproxy golang git
      fi

      #{$install_consul}
      #{$consul_node.call("192.168.33.11")}
      sudo cp /vagrant/proxy/proxy.json /etc/consul.d/agent/
      sudo service consul restart
      #{$install_consul_template}
      echo "ENABLED=1" > /etc/default/haproxy
      if [ ! -e /etc/init/proxy.conf ]
        then
          sudo foreman export upstart /etc/init -u root --procfile /vagrant/proxy/Procfile.haproxy --app proxy
      fi
      sudo service proxy restart
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
        sudo cp /vagrant/counter/app.json /etc/consul.d/agent/
        sudo sed -i'' -e 's/\:id\:/app-#{i}/' /etc/consul.d/agent/app.json
        sudo sed -i'' -e 's/\:ip\:/#{ip}/' /etc/consul.d/agent/app.json
        sudo service consul restart
        if [ ! -e /etc/init/app.conf ]
          then
            echo "BIND_ADDR=\\"#{ip}\\"" >> /tmp/.env
            sudo foreman export upstart /etc/init -u vagrant --procfile /vagrant/counter/Procfile --env /tmp/.env --app counter
        fi
        sudo service counter restart
      SHELL

      app.vm.hostname = "app-#{i}"
      app.vm.network "private_network", ip: ip
    end
  end
end
