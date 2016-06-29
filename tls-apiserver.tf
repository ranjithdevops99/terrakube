# generate apiserver private key
# openssl genrsa -out apiserver-key.pem 2048
resource "tls_private_key" "apiserver" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

# generate apiserver csr
# openssl req -new -key apiserver-key.pem -out apiserver.csr -subj "/CN=kube-apiserver" -config openssl.cnf
resource "tls_cert_request" "apiserver" {
  key_algorithm   = "RSA"
  private_key_pem = "${tls_private_key.apiserver.private_key_pem}"

  subject {
    common_name = "kube-apiserver"
  }

  dns_names = [
    "kubernetes",
    "kubernetes.default",
    "kubernetes.default.svc",
    "kubernetes.default.svc.cluster.local",
    "coreos0",
  ]

  ip_addresses = [
    "${var.k8s_service_ip}",
    "${openstack_networking_port_v2.local.0.fixed_ip.0.ip_address}",
    "${openstack_networking_floatingip_v2.remote.0.address}",
  ]
}

# sign apiserver csr
# openssl x509 -req -in apiserver.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out apiserver.pem -days 365 -extensions v3_req -extfile openssl.cnf
resource "tls_locally_signed_cert" "apiserver" {
  cert_request_pem   = "${tls_cert_request.apiserver.cert_request_pem}"
  ca_key_algorithm   = "RSA"
  ca_private_key_pem = "${tls_private_key.ca.private_key_pem}"
  ca_cert_pem        = "${tls_self_signed_cert.ca.cert_pem}"

  validity_period_hours = "9999"

  allowed_uses = [
    "nonRepudiation",
    "key_encipherment",
    "digital_signature",
    "any_extended",
  ]
}

resource "consul_keys" "apiserver" {
  key {
    name   = "apiserver"
    path   = "etc/kubernetes/ssl/apiserver.pem"
    value  = "${tls_locally_signed_cert.apiserver.cert_pem}"
    delete = true
  }

  key {
    name   = "apiserver_key"
    path   = "etc/kubernetes/ssl/apiserver-key.pem"
    value  = "${tls_private_key.apiserver.private_key_pem}"
    delete = true
  }
}
