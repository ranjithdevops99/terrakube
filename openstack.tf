# Configure the OpenStack Provider
provider "openstack" {
    user_name = "${var.os_user_name}"
    tenant_name = "${var.os_tenant_name}"
    password = "${var.os_password}"
    auth_url = "${var.os_auth_url}"
}

# TODO: This should really generate its own network, subnet, & security group
resource "openstack_networking_port_v2" "local" {
  count = "${var.nodes}"
  name = "local_${count.index}"
  network_id = "${var.internal_network_id}"
  fixed_ip {
      "subnet_id" =  "${var.internal_subnet_id}"
  }
  security_group_ids = ["${var.default_security_group}"]
  admin_state_up = "true"
}

resource "openstack_networking_floatingip_v2" "remote" {
  count = "${var.nodes}"
  pool = "ext-net"
}

# TODO don't hardcode key-pair user. generate key pair? set via variable? hmmm
resource "openstack_compute_instance_v2" "coreos" {
  count = "${var.nodes}"
  name = "coreos${count.index}"
  image_name = "coreos-${var.coreos_release}"
  flavor_name = "m1.medium"
  key_pair = "goat"
  network {
    port = "${element(openstack_networking_port_v2.local.*.id, count.index)}"
    floating_ip = "${element(openstack_networking_floatingip_v2.remote.*.address, count.index)}"
  }
  user_data = "${element(template_file.master_cloud_config.*.rendered, count.index)}"

  # enable kube-system namespace
  provisioner "remote-exec" {
    inline = [
      "until ( $(sudo netstat -tnlp | grep 8080 &> /dev/null) ); do sleep 10; echo waiting for apiserver to start; done",
      "curl -H \"Content-Type: application/json\" -X POST -d'{\"apiVersion\":\"v1\",\"kind\":\"Namespace\",\"metadata\":{\"name\":\"kube-system\"}}' http://127.0.0.1:8080/api/v1/namespaces"
    ]
    connection {
      host = "${element(openstack_networking_floatingip_v2.remote.*.address, count.index)}"
      user = "core"
      private_key = "${file("/home/goat/.ssh/id_rsa")}"
    }
  }
}

# TODO: convert oems from files to inline
resource "null_resource" "kube_setup" {
  #depends_on = ["openstack_compute_instance_v2.coreos"]

  # wripte out certificates
  provisioner "local-exec" {
    command = "echo \"${tls_self_signed_cert.ca.cert_pem}\" > /tmp/ca.pem"
  }
  provisioner "local-exec" {
    command = "echo \"${tls_locally_signed_cert.admin.cert_pem}\" > /tmp/admin.pem"
  }
  provisioner "local-exec" {
    command = "echo \"${tls_private_key.admin.private_key_pem}\" > /tmp/admin-key.pem"
  }

  # setup kubectl
  provisioner "local-exec" {
    command = "./setup_kubectl.sh ${openstack_networking_floatingip_v2.remote.0.address} ${var.nodes}"
  }
}

output "master_ip" {
  value = "${openstack_networking_floatingip_v2.remote.0.address}"
}
