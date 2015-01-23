consul = "127.0.0.1:8500"
retry = "10s"

template {
  source = "/vagrant/proxy/haproxy.ctmpl"
  destination = "/tmp/haproxy-intermediate.ctmpl"
}

template {
  source = "/tmp/haproxy-intermediate.ctmpl"
  destination = "/etc/haproxy/haproxy.cfg"
  command = "service haproxy reload"
}
