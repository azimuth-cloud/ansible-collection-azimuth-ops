# ansible-collection-azimuth-ops

This [Ansible collection](https://docs.ansible.com/ansible/latest/user_guide/collections_using.html)
contains roles and playbooks for deploying [Azimuth](https://github.com/azimuth-cloud/azimuth) and
all of its dependencies.

It can function in three modes:

1. Deploy Azimuth onto a pre-existing Kubernetes cluster.
2. Provision a single-node [K3S](https://k3s.io/) cluster into an
   [OpenStack](https://www.openstack.org/) project using [OpenTofu](https://opentofu.org/)
   and deploy Azimuth onto it.
3. Provision a single-node K3S cluster into an OpenStack project using OpenTofu, configure
   it as a [Cluster API](https://cluster-api.sigs.k8s.io/) management cluster, use it
   to deploy a high-availability Kubernetes cluster into the same OpenStack project using
   Cluster API and finally deploy Azimuth onto the high-availability cluster.

This collection is designed to be used with a configuration repository that is forked
from [azimuth-config](https://github.com/azimuth-cloud/azimuth-config), and user documentation
for configuration options can be found in that project.

## Developing locally

To run the GitHub Actions linters locally, use:

```sh
docker run --rm \
    -e RUN_LOCAL=true \
    --env-file "super-linter.env" \
    -v "$(pwd)":/tmp/lint \
    ghcr.io/super-linter/super-linter:v7.3.0
```

```sh
ansible-lint -c .ansible-lint.yml
```

### MacOS

The super-linter project does not currently build arm64 container images,
therefore running locally on M-series Mac devices requires an additional
`--platform linux/amd64` argument to the `docker run` command above.
