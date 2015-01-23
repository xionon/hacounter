# -*- mode: ruby -*-
# vi: set ft=ruby :

$base_box = "ubuntu/trusty64"

Vagrant.configure(2) do |config|
  config.vm.define("consul") do |consul|
    ip =  "192.168.33.10"

    consul.vm.box = $base_box
    consul.vm.hostname = "consul"
    consul.vm.network "private_network", ip: ip

    consul.vm.provision "shell", path: "scripts/baseline.sh"
    consul.vm.provision "shell", path: "scripts/consul_server.sh", args: [ip]
  end

  config.vm.define("proxy") do |proxy|
    ip = "192.168.33.11"

    proxy.vm.box = $base_box
    proxy.vm.network "forwarded_port", guest: 8080, host: 8080
    proxy.vm.hostname = "proxy"
    proxy.vm.network "private_network", ip: ip

    proxy.vm.provision "shell", path: "scripts/baseline.sh"
    proxy.vm.provision "shell", path: "scripts/consul_node.sh", args: [ip]
    proxy.vm.provision "shell", path: "scripts/haproxy.sh"
  end

  3.times do |i|
    config.vm.define("app-#{i}") do |app|
      ip = "192.168.33.#{i+20}"

      app.vm.box = $base_box
      app.vm.hostname = "app-#{i}"
      app.vm.network "private_network", ip: ip

      app.vm.provision "shell", path: "scripts/baseline.sh"
      app.vm.provision "shell", path: "scripts/consul_node.sh", args: [ip]
      app.vm.provision "shell", path: "scripts/app.sh", args: [ip, i]
    end
  end

  config.vm.define("redis") do |redis|
    ip =  "192.168.33.30"

    redis.vm.box = $base_box
    redis.vm.hostname = "redis"
    redis.vm.network "private_network", ip: ip

    redis.vm.provision "shell", path: "scripts/baseline.sh"
    redis.vm.provision "shell", path: "scripts/consul_node.sh", args: [ip]
    redis.vm.provision "shell", path: "scripts/redis.sh", args: [ip]
  end
end
