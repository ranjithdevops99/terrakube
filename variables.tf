##############################################################################
# cluster setup
##############################################################################

# coreos release branch
variable "coreos_release" {
  default = "beta"
}

# kubernetes verson to install
# list of tags here https://quay.io/repository/coreos/hyperkube?tab=tags
variable "k8s_ver" {
  default = "v1.3.6_coreos.0"
}

# number of nodes in cluster
variable "nodes" {
  default = "3"
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

##############################################################################
# kubernetes network
##############################################################################
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
  default = "10.1.0.1"
}

##############################################################################
# openstaack provider config
##############################################################################

variable "os_flavor" {
  default = "m1.medium"
}

variable "os_keypair" {
  default = "monkey"
}

variable "os_keypair_private" {
  default = "/home/goat/.ssh/id_rsa"
}

variable "os_domain_name" {
  default = "default"
}

variable "os_tenant_name" {
  default = "admin"
}

variable "os_user_name" {
  default = "admin"
}

variable "os_password" {
  default = "password"
}

variable "os_auth_url" {
  default = "http://10.1.0.15:35357/v3"
}

variable "internal_network_id" {
  default = "891b4750-2692-4ff2-afed-356b9d182df7"
}

variable "internal_subnet_id" {
  default = "c8809265-7f38-4df9-a45c-ba704e922481"
}

variable "external_network_id" {
  default = "891b4750-2692-4ff2-afed-356b9d182df7"
}

variable "default_security_group" {
  default = "7d53dc89-3eb8-4107-8800-8658a7394e30"
}

##############################################################################
# consul provider config
##############################################################################
variable "consul_address" {
  default = "useless.mass.goathorde.org:8500"
}
