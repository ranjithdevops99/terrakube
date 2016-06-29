provider "consul" {
    address = "${var.consul_address}"
    scheme = "http"
    datacenter = "dc1"
}
