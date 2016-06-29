# generate worker private key
# openssl genrsa -out coreos-worker-key.pem 2048
resource "tls_private_key" "coreos" {
    count = "${var.nodes}"
    algorithm = "RSA"
    rsa_bits = "2048"
}

# generate worker csr
# openssl req -new -key coreos1-worker-key.pem -out coreos1-worker.csr -subj "/CN=coreos1" -config worker-openssl.cnf
resource "tls_cert_request" "coreos" {
    count = "${var.nodes}"
    key_algorithm = "RSA"
    private_key_pem = "${element(tls_private_key.coreos.*.private_key_pem, count.index)}"

    subject {
        common_name = "coreos${count.index}"
        organization = "kube"
    }

    dns_names = [
      "coreos${count.index}",
      "coreos${count.index}.default",
      "coreos${count.index}.default.svc",
      "coreos${count.index}.default.svc.cluster.local"
    ]

    ip_addresses = [
      "${element(openstack_networking_port_v2.local.*.fixed_ip.0.ip_address, count.index)}"
    ]
}

# sign worker csr
# openssl x509 -req -in coreos1-worker.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out coreos1-worker.pem -days 365 -extensions v3_req -extfile worker-openssl.cnf
resource "tls_locally_signed_cert" "coreos" {
    count = "${var.nodes}"
    cert_request_pem = "${element(tls_cert_request.coreos.*.cert_request_pem, count.index)}"
    ca_key_algorithm = "RSA"
    ca_private_key_pem = "${tls_private_key.ca.private_key_pem}"
    ca_cert_pem = "${tls_self_signed_cert.ca.cert_pem}"

    validity_period_hours = "9999"

    allowed_uses = [
        "nonRepudiation",
        "key_encipherment",
        "digital_signature",
        "any_extended"
    ]
}

resource "consul_keys" "coreos" {
  count = "${var.nodes}"
  key {
    name = "coreos${count.index}"
    path = "etc/kubernetes/ssl/coreos${count.index}.pem"
    value = "${element(tls_locally_signed_cert.coreos.*.cert_pem, count.index)}"
    delete = true
  }

  key {
    name = "coreos${count.index}_key"
    path = "etc/kubernetes/ssl/coreos${count.index}-key.pem"
    value = "${element(tls_private_key.coreos.*.private_key_pem, count.index)}"
    delete = true
  }
}
