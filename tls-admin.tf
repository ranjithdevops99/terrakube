# generate admin private key
# openssl genrsa -out admin-key.pem 2048
resource "tls_private_key" "admin" {
    algorithm = "RSA"
    rsa_bits = "2048"
}

# generate admin csr
# openssl req -new -key admin-key.pem -out admin.csr -subj "/CN=admin" -config admin-openssl.cnf
resource "tls_cert_request" "admin" {
    key_algorithm = "RSA"
    private_key_pem = "${tls_private_key.admin.private_key_pem}"

    subject {
        common_name = "kube-admin"
    }
}

# sign worker csr
# openssl x509 -req -in admin.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out admin.pem -days 365 -extensions v3_req -extfile admin.cnf
resource "tls_locally_signed_cert" "admin" {
    cert_request_pem = "${tls_cert_request.admin.cert_request_pem}"
    ca_key_algorithm = "RSA"
    ca_private_key_pem = "${tls_private_key.ca.private_key_pem}"
    ca_cert_pem = "${tls_self_signed_cert.ca.cert_pem}"

    validity_period_hours = "9999"
    allowed_uses = [
      "any_extended"
    ]
}

resource "consul_keys" "admin" {
  key {
    name = "admin"
    path = "etc/kubernetes/ssl/admin.pem"
    value = "${tls_locally_signed_cert.admin.cert_pem}"
    delete = true
  }

  key {
    name = "admin_key"
    path = "etc/kubernetes/ssl/admin-key.pem"
    value = "${tls_private_key.admin.private_key_pem}"
    delete = true
  }
}
