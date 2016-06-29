# generate CA private key
# openssl genrsa -out ca-key.pem 2048
resource "tls_private_key" "ca" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

# generate CA self signed cert
# openssl req -x509 -new -nodes -key ca-key.pem -days 10000 -out ca.pem -subj "/CN=kube-ca"
resource "tls_self_signed_cert" "ca" {
  key_algorithm   = "RSA"
  private_key_pem = "${tls_private_key.ca.private_key_pem}"

  subject {
    common_name = "kube-ca"
  }

  validity_period_hours = "9999"
  allowed_uses          = []
  is_ca_certificate     = "true"
}

resource "consul_keys" "ca" {
  key {
    name   = "ca"
    path   = "etc/kubernetes/ssl/ca.pem"
    value  = "${tls_self_signed_cert.ca.cert_pem}"
    delete = true
  }
}
