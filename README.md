# ansible-collection-azimuth-ops

This [Ansible collection](https://docs.ansible.com/ansible/latest/user_guide/collections_using.html)
contains roles and playbooks for deploying [Azimuth](https://github.com/stackhpc/azimuth) and
all of its dependencies onto a [Kubernetes](https://kubernetes.io/) cluster.

It can function in three configurations:

  1. Deploy Azimuth onto a pre-existing Kubernetes cluster.
  1. Provision a single-node [K3S](https://k3s.io/) cluster into an
     [OpenStack](https://www.openstack.org/) project using [Terraform](https://www.terraform.io/)
     and deploy Azimuth onto it.
  1. Provision a single-node K3S cluster as a seed node using Terraform, configure
     it as a [Cluster API](https://cluster-api.sigs.k8s.io/) management cluster, use it
     to deploy a HA cluster using Cluster API and deploy Azimuth onto the HA cluster.
