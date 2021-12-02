output "cluster_gateway_ip" {
  description = "The IP address of the gateway used to contact the cluster nodes"
  value       = var.floatingip_address
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
        }
      }
    ]
  )
}
