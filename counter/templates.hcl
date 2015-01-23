consul = "127.0.0.1:8500"
retry = "10s"

template {
  source = "/vagrant/counter/redis.ctmpl"
  destination = "/vagrant/counter/redis.yml"
  command = "sudo service counter-web restart"
}
