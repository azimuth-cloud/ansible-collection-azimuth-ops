variable "cluster_name" {
  type        = string
  description = "The name of the cluster"
}

variable "external_network_id" {
  type        = string
  description = "The ID of the external network to use"
}

variable "network_cidr" {
  type        = string
  description = "The CIDR of the network"
}

variable "image_id" {
  type        = string
  description = "The id of the image to use"
}

variable "flavor_id" {
  type        = string
  description = "The id of the flavor to use"
}

variable "key_pair" {
  type        = string
  description = "The name of the key pair to use"
}

variable "data_volume_size" {
  type        = number
  description = "The size in GB for the data volume"
}

variable "floatingip_address" {
  type        = string
  description = "The address of the floating IP to use"
}
