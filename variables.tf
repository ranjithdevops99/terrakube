### coreos config ###
variable "coreos_release" {
  default = "stable"
}

# kubernetes verson
variable "k8s_ver" {
  default = "v1.2.4_coreos.1"
}

# list of nodes & their associate role config file
variable "role" {
  default = {
    "0" = "cloud-init/master.yaml"
    "1" = "cloud-init/node.yaml"
    "2" = "cloud-init/node.yaml"
  }
}

# number of node to setup
variable "nodes" {
  default = "1"
}

### openstaack provider config ###
variable "os_user_name" {
  default = "admin"
}

variable "os_tenant_name" {
  default = "admin"
}

variable "os_tenant_id" {
  default = "9f91c6cc52ed450096ef40da32a862dc"
}

variable "os_password" {
  default = "password"
}

variable "os_auth_url" {
  default = "http://nak.mass.goathorde.org:5000/v2.0"
}

variable "internal_network_id" {
  default = "23a2630b-51f4-4472-ab99-cbf41cbd43b9"
}

variable "internal_subnet_id" {
  default = "deb5ed27-ecdd-4b94-a872-1dfdcd49c9c8"
}

variable "external_network_id" {
  default = "0976f4c4-0f33-4373-95b5-de4689e393c5"
}

variable "default_security_group" {
  default = "12b3bf1c-0862-4406-8c2b-afc807c37d69"
}

### consul provider config ###
variable "consul_address" {
  default = "useless.mass.goathorde.org:8500"
}

### kubernetes networks ###
variable "pod_network" {
  default = "10.2.0.0/16"
}

variable "service_ip_network" {
  default = "10.3.0.0/24"
}

variable "k8s_service_ip" {
  default = "10.3.0.1"
}

variable "dns_service_ip" {
  default = "10.3.0.10"
}
