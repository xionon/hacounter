consul = "127.0.0.1:8500"
retry = "10s"

template {
  source = "/vagrant/proxy/haproxy-without-weights.ctmpl"
  destination = "/etc/haproxy/haproxy.cfg"
  command = "service haproxy reload"
}
