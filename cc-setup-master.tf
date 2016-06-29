# list of etcd cluster client endpoints
resource "template_file" "etcd_endpoints" {
  count = "${var.nodes}"
  template = "http://${ip}:2379"
  vars {
    ip = "${element(openstack_networking_port_v2.local.*.fixed_ip.0.ip_address, count.index)}"
  }
}

# list of etcd cluster servers
resource "template_file" "cluster_list" {
  count = "${var.nodes}"
  template = "coreos${n}=http://${ip}:2380"
  vars {
    n = "${count.index}"
    ip = "${element(openstack_networking_port_v2.local.*.fixed_ip.0.ip_address, count.index)}"
  }
}

# openstack config file
resource "template_file" "os_cloud_cfg" {
  template = "${file("templates/conf/cloud.cfg")}"
  vars {
    os_user_name = "${var.os_user_name}"
    os_tenant_id = "${var.os_tenant_id}"
    os_password = "${var.os_password}"
    os_auth_url = "${var.os_auth_url}"
    internal_subnet_id = "${var.internal_subnet_id}"
    external_network_id = "${var.external_network_id}"
  }
}
resource "consul_keys" "os_cloud_cfg" {
  key {
    name = "cloud_cfg"
    path = "etc/cloud.cfg"
    value = "${template_file.os_cloud_cfg.rendered}"
    delete = true
  }
}

resource "consul_keys" "auth_txt" {
  key {
    name = "auth_txt"
    path = "etc/kubernetes/ssl/auth.txt"
    value = "password,admin,admin"
    delete = true
  }
}

# setup kubelet service
resource "template_file" "kubelet_master_service" {
  template = "${file("templates/service/kubelet.master.service")}"
  vars {
    k8s_ver = "${var.k8s_ver}"
    dns_service_ip = "${var.dns_service_ip}"
    ip = "${element(openstack_networking_port_v2.local.*.fixed_ip.0.ip_address, count.index)}"
  }
}
# TODO problem - this file will be different for each node
resource "consul_keys" "kubelet_master_service" {
  key {
    name = "kubelet_master_service"
    path = "etc/systemd/system/kubelet.service"
    value = "${template_file.kubelet_master_service.rendered}"
    delete = true
  }
}

# setup kube-apiserver pod
resource "template_file" "kube_apiserver_pod" {
  template = "${file("templates/pod/kube-apiserver.yaml")}"
  vars {
    k8s_ver = "${var.k8s_ver}"
    service_ip_network = "${var.service_ip_network}"
    etcd_endpoints = "${join(",", template_file.etcd_endpoints.*.rendered)}"
    ip = "${element(openstack_networking_port_v2.local.*.fixed_ip.0.ip_address, count.index)}"
  }
}
resource "consul_keys" "kube_apiserver_pod" {
  key {
    name = "kube_apiserver_pod"
    path = "etc/kubernetes/manifests/kube-apiserver.yaml"
    value = "${template_file.kube_apiserver_pod.rendered}"
    delete = true
  }
}

# setup kube-proxy pod
resource "template_file" "kube_proxy_pod" {
  template = "${file("templates/pod/kube-proxy.yaml")}"
  vars {
    k8s_ver = "${var.k8s_ver}"
  }
}
resource "consul_keys" "kube_proxy_pod" {
  key {
    name = "kube_proxy_pod"
    path = "etc/kubernetes/manifests/kube-proxy.yaml"
    value = "${template_file.kube_proxy_pod.rendered}"
    delete = true
  }
}

# setup kube-controller-manager pod
resource "template_file" "kube_controller_manager_pod" {
  template = "${file("templates/pod/kube-controller-manager.yaml")}"
  vars {
    k8s_ver = "${var.k8s_ver}"
  }
}
resource "consul_keys" "kube_controller_manager_pod" {
  key {
    name = "kube_controller_manager_pod"
    path = "etc/kubernetes/manifests/kube-controller-manager.yaml"
    value = "${template_file.kube_controller_manager_pod.rendered}"
    delete = true
  }
}

# setup kube-scheduler pod
resource "template_file" "kube_scheduler_pod" {
  template = "${file("templates/pod/kube-scheduler.yaml")}"
  vars {
    k8s_ver = "${var.k8s_ver}"
  }
}
resource "consul_keys" "kube_scheduler_pod" {
  key {
    name = "kube_scheduler_pod"
    path = "etc/kubernetes/manifests/kube-scheduler.yaml"
    value = "${template_file.kube_scheduler_pod.rendered}"
    delete = true
  }
}

# render final user-data template
resource "template_file" "master_cloud_config" {
  count = "${var.nodes}"
  template = "${file(lookup(var.role, count.index))}"
  vars {
    node_name = "coreos${count.index}"
    node_ip = "${element(openstack_networking_port_v2.local.*.fixed_ip.0.ip_address, count.index)}"
    master_ip = "${openstack_networking_port_v2.local.0.fixed_ip.0.ip_address}"
    cluster_list = "${join(",", template_file.cluster_list.*.rendered)}"
    etcd_endpoints = "${join(",", template_file.etcd_endpoints.*.rendered)}"
    pod_network = "${var.pod_network}"
  }
}
