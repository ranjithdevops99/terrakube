### coreos config ###
variable "coreos_release" {
  default = "beta"
}

# kubernetes verson
variable "k8s_ver" {
  default = "v1.2.4_coreos.1"
}

# map nodes to cloud-init file
variable "cloud_init" {
  default = {
    "0" = "templates/cloud-init/master.yaml"
    "1" = "templates/cloud-init/node.yaml"
    "2" = "templates/cloud-init/node.yaml"
  }
}

# map nodes to kubelet service file
variable "kubelet_service_file" {
  default = {
    "0" = "templates/service/kubelet.master.service"
    "1" = "templates/service/kubelet.node.service"
    "2" = "templates/service/kubelet.node.service"
  }
}

# number of node to setup
variable "nodes" {
  default = "3"
}

### openstaack provider config ###
variable "os_user_name" {
  default = "admin"
}

variable "os_tenant_name" {
  default = "admin"
}

variable "os_tenant_id" {
  default = "ca7e9ca93265493ca83af02d9ab332ac"
}

variable "os_password" {
  default = "password"
}

variable "os_auth_url" {
  default = "http://10.1.0.15:5000/v2.0"
}

variable "internal_network_id" {
  default = "891b4750-2692-4ff2-afed-356b9d182df7"
}

variable "internal_subnet_id" {
  default = "c8809265-7f38-4df9-a45c-ba704e922481"
}

variable "external_network_id" {
  default = "0976f4c4-0f33-4373-95b5-de4689e393c5"
}

variable "default_security_group" {
  default = "f24da18e-253d-4eba-93f0-cb684b5108fe"
}

### consul provider config ###
variable "consul_address" {
  default = "useless.mass.goathorde.org:8500"
}

### kubernetes networks ###
variable "pod_network" {
  default = "10.4.0.0/16"
}

variable "service_ip_network" {
  default = "10.5.0.0/24"
}

variable "k8s_service_ip" {
  default = "10.5.0.1"
}

variable "dns_service_ip" {
  default = "10.5.0.10"
}
