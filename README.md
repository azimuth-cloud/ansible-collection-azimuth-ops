# ansible-capi-manage

[Ansible](https://www.ansible.com/) playbook to deploy a
[Cluster API](https://github.com/kubernetes-sigs/cluster-api) management cluster from scratch.

It can use [Terraform](https://www.terraform.io/) to provision infrastructure - currently
resources exist to provision infrastructure on an [OpenStack](https://www.openstack.org/).

Kubernetes is deployed using [k3s](https://k3s.io/).
