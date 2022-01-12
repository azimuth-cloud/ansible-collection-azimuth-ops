output "cluster_ssh_private_key" {
  description = "The generated private key for the cluster"
  value       = openstack_compute_keypair_v2.capi_manager_deploy.private_key
}

output "cluster_gateway_ip" {
  description = "The IP address of the gateway used to contact the cluster nodes"
  value       = openstack_networking_floatingip_v2.capi_manager_fip.address
}

output "cluster_nodes" {
  description = "A list of the nodes in the cluster from which an Ansible inventory will be populated"
  value       = concat(
    [
      {
        name          = openstack_compute_instance_v2.capi_manager.name
        ip            = openstack_compute_instance_v2.capi_manager.network[0].fixed_ip_v4
        primary_group = "capi_managers"
        facts         = {
          k3s_storage_device = openstack_compute_volume_attach_v2.capi_manager.device
          # Include the network id of the CAPI manager as a variable for provisioned hosts
          # This allows clusters to be placed onto the network by referencing this
          capi_manager_network_id = data.openstack_networking_network_v2.capi_manager.id
          # Also include the keypair name for the same reason
          capi_manager_keypair = openstack_compute_keypair_v2.capi_manager_deploy.name
        }
      }
    ]
  )
}
