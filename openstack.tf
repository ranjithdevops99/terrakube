# Configure the OpenStack Provider
provider "openstack" {
  domain_name = "${var.os_domain_name}"
  tenant_name = "${var.os_tenant_name}"
  user_name   = "${var.os_user_name}"
  password    = "${var.os_password}"
  auth_url    = "${var.os_auth_url}"
}

# TODO: This should really generate its own network, subnet, & security group
resource "openstack_networking_port_v2" "local" {
  count      = "${var.nodes}"
  name       = "local_${count.index}"
  network_id = "${var.internal_network_id}"

  fixed_ip {
    "subnet_id" = "${var.internal_subnet_id}"
  }

  security_group_ids = ["${var.default_security_group}"]
  admin_state_up     = "true"
}

#resource "openstack_networking_floatingip_v2" "remote" {
#  count = "${var.nodes}"
#  pool  = "ext-net"
#}

# TODO don't hardcode key-pair user. generate key pair? set via variable? hmmm
resource "openstack_compute_instance_v2" "coreos" {
  count       = "${var.nodes}"
  name        = "coreos${count.index}"
  image_name  = "coreos-${var.coreos_release}"
  flavor_name = "m1.coreos"
  key_pair    = "monkey"

  network {
    port        = "${element(openstack_networking_port_v2.local.*.id, count.index)}"
    #floating_ip = "${element(openstack_networking_floatingip_v2.remote.*.address, count.index)}"
  }

  user_data = "${element(template_file.master_cloud_config.*.rendered, count.index)}"

  provisioner "file" {
      source = "templates/scripts/pause_until_ready.sh"
      destination = "/tmp/pause_until_ready.sh"
      connection {
        #host        = "${element(openstack_networking_floatingip_v2.remote.*.address, count.index)}"
        host        = "${element(openstack_networking_port_v2.local.*.fixed_ip.0.ip_address, count.index)}"
        user        = "core"
        private_key = "${file("/home/goat/.ssh/id_rsa")}"
      }
  }

  # pause until apiserver on 8080 starts responding
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/pause_until_ready.sh",
      "/tmp/pause_until_ready.sh"
    ]
    connection {
      #host        = "${element(openstack_networking_floatingip_v2.remote.*.address, count.index)}"
      host        = "${element(openstack_networking_port_v2.local.*.fixed_ip.0.ip_address, count.index)}"
      user        = "core"
      private_key = "${file("/home/goat/.ssh/id_rsa")}"
    }
  }
}

# TODO: convert oems from files to inline
resource "null_resource" "kube_setup" {
  #depends_on = ["openstack_compute_instance_v2.coreos"]

  #  write out certificates
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
    command = "./templates/scripts/setup_kubectl.sh ${openstack_networking_port_v2.local.0.fixed_ip.0.ip_address}"
  }

  #provisioner "local-exec" {
  #  command = "rm -f /tmp/ca.pem /tmp/admin.pem /tmp/admin-key.pem"
  #}

}

output "master_ip" {
  value = "${openstack_networking_port_v2.local.0.fixed_ip.0.ip_address}"
}
