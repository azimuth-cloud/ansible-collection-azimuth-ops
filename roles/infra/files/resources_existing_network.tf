#####
##### Terraform resources for provisioning a CAPI manager
##### with an existing tenant network
#####

data "openstack_networking_network_v2" "capi_manager" {
  name       = var.existing_network_name
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
    port = data.openstack_networking_port_v2.capi_manager.id
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

