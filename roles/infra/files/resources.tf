#####
##### Terraform resources for provisioning a CAPI manager
#####

resource "openstack_networking_secgroup_v2" "capi_manager" {
  name                 = var.cluster_name
  description          = "Rules for the CAPI manager"
  delete_default_rules = true   # Fully manage with terraform
}

resource "openstack_networking_secgroup_rule_v2" "capi_manager_egress" {
  direction         = "egress"
  ethertype         = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.capi_manager.id
}

resource "openstack_networking_secgroup_rule_v2" "capi_manager_ingress_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  security_group_id = openstack_networking_secgroup_v2.capi_manager.id
}

resource "openstack_networking_network_v2" "capi_manager" {
  name           = var.cluster_name
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "capi_manager" {
  name       = var.cluster_name
  network_id = openstack_networking_network_v2.capi_manager.id
  cidr       = var.network_cidr
  ip_version = 4
}

resource "openstack_networking_router_v2" "capi_manager" {
  name                = var.cluster_name
  admin_state_up      = "true"
  external_network_id = var.external_network_id
}

resource "openstack_networking_router_interface_v2" "capi_manager" {
  router_id = openstack_networking_router_v2.capi_manager.id
  subnet_id = openstack_networking_subnet_v2.capi_manager.id
}

resource "openstack_networking_port_v2" "capi_manager" {
  name           = var.cluster_name
  admin_state_up = "true"
  network_id     = openstack_networking_network_v2.capi_manager.id

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.capi_manager.id
  }

  security_group_ids = [
    openstack_networking_secgroup_v2.capi_manager.id
  ]
}

resource "openstack_compute_keypair_v2" "capi_manager_deploy" {
  name       = "capi-manager-deploy"
}

resource "openstack_compute_instance_v2" "capi_manager" {
  name      = var.cluster_name
  image_id  = var.image_id
  flavor_id = var.flavor_id
  key_pair  = openstack_compute_keypair_v2.capi_manager_deploy.name

  network {
    port = openstack_networking_port_v2.capi_manager.id
  }
}

resource "openstack_blockstorage_volume_v3" "capi_manager_data" {
  name = "${var.cluster_name}-data"
  size = var.data_volume_size
}

resource "openstack_compute_volume_attach_v2" "capi_manager" {
  instance_id = openstack_compute_instance_v2.capi_manager.id
  volume_id   = openstack_blockstorage_volume_v3.capi_manager_data.id
}

resource "openstack_networking_floatingip_v2" "capi_manager_fip" {
  pool = var.floatingip_pool
}

resource "openstack_compute_floatingip_associate_v2" "capi_manager" {
  floating_ip = openstack_networking_floatingip_v2.capi_manager_fip.address
  instance_id = openstack_compute_instance_v2.capi_manager.id
}
