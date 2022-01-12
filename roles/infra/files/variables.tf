variable "cluster_name" {
  type        = string
  description = "The name of the cluster"
}

variable "external_network_id" {
  type        = string
  description = "The ID of the external network to use"
  default     = "false"
}

variable "network_cidr" {
  type        = string
  description = "The CIDR of the network"
  default     = "false"
}

variable "existing_network_name" {
  type        = string
  description = "The name of an existing tenant network to use"
  default     = "false"
}

variable "image_id" {
  type        = string
  description = "The id of the image to use"
}

variable "flavor_id" {
  type        = string
  description = "The id of the flavor to use"
}

variable "data_volume_size" {
  type        = number
  description = "The size in GB for the data volume"
}

variable "floatingip_pool" {
  type        = string
  description = "The pool to use for floating IP allocation"
}
