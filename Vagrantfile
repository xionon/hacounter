# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  config.vm.define("consul") do |consul|
    consul.vm.box = "chef/ubuntu-14.04"
    consul.vm.provision "shell", inline: <<-SHELL
      if [ ! `which redis-server` ]
      then
        sudo apt-get update -y
        sudo apt-get upgrade -y
        sudo apt-get install -y unzip redis-server vim
        sudo sed -i '.bak' -e 's/bind 127/bind 192.168.33.10 127/' /etc/redis/redis.conf
      fi

      if [ ! -e /usr/local/bin/consul ]
      then
        cd /tmp
        wget https://dl.bintray.com/mitchellh/consul/0.4.1_linux_amd64.zip
        unzip 0.4.1_linux_amd64.zip
        sudo mv /tmp/consul /usr/local/bin/consul
      fi
    SHELL

    consul.vm.network "private_network", ip: "192.168.33.10"
  end

  config.vm.define("proxy") do |proxy|
    proxy.vm.box = "chef/ubuntu-14.04"
    proxy.vm.network "forwarded_port", guest: 80, host: 8080
    proxy.vm.provision "shell", inline: <<-SHELL
      if [ ! `which haproxy` ]
      then
        sudo apt-get update -y
        sudo apt-get upgrade -y
        sudo apt-get install -y haproxy vim golang git
      fi

      if [ ! -e /usr/local/bin/consul-template ]
      then
        git clone https://github.com/hashicorp/consul-template.git /tmp/consul-template
        cd /tmp/consul-template
        make
        mv /tmp/consul-template/bin/consul-template /usr/local/bin/consul-template
      fi
    SHELL

    proxy.vm.network "private_network", ip: "192.168.33.11"
  end

  3.times do |i|
    config.vm.define("app-#{i}") do |app|
      app.vm.box = "chef/ubuntu-14.04"
      app.vm.provision "shell", inline: <<-SHELL
        if [ ! `rvm --version` ]
        then
          sudo apt-get update -y
          sudo apt-get upgrade -y
          sudo apt-get install -y curl vim
          gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3
          \\curl -sSL https://get.rvm.io | bash -s stable --rails
        fi
      SHELL

      app.vm.network "private_network", ip: "192.168.33.#{i + 20}"
    end
  end
end
