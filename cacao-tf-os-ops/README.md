# cacao-tf-os-ops

## purpose
internal-cacao terraform scripts that may be used to provision different resources in openstack

## setup
[dockerfile example available here](https://gitlab.com/cyverse/cacao-argo-ansible/-/blob/master/ansible/Dockerfile)

bash:
```
#!/bin/bash

# versions
export TERRAFORM_VER=0.14.4
export OPENSTACK_PROVIDER_VER=1.32.0

# dependencies
DEBIAN_FRONTEND=noninteractive apt-get install -qq -y --no-install-recommends wget zip ansible curl unzip

cd /tmp

# install the terraform binary in /usr/bin
wget https://releases.hashicorp.com/terraform/${TERRAFORM_VER}/terraform_${TERRAFORM_VER}_linux_amd64.zip
unzip terraform_${TERRAFORM_VER}_linux_amd64.zip
chmod +x ./terraform
sudo mv ./terraform /usr/bin

# install the openstack provider in
wget https://github.com/terraform-provider-openstack/terraform-provider-openstack/releases/download/v${OPENSTACK_PROVIDER_VER}/terraform-provider-openstack_${OPENSTACK_PROVIDER_VER}_linux_amd64.zip
unzip terraform-provider-openstack_${OPENSTACK_PROVIDER_VER}_linux_amd64.zip
chmod +x terraform-provider-openstack_v${OPENSTACK_PROVIDER_VER}
mkdir -p /$USER/.terraform.d/plugins/terraform.cyverse.org/cyverse/openstack/${OPENSTACK_PROVIDER_VER}/linux_amd64
mv terraform-provider-openstack_v${OPENSTACK_PROVIDER_VER} /$USER/.terraform.d/plugins/terraform.cyverse.org/cyverse/openstack/${OPENSTACK_PROVIDER_VER}/linux_amd64/
```

## examples
examples expect users to source a complete openrc file that specifies a project

### attach_share_interface
this example requires 2 variables:
  - instance_uuid
  - share_network_uuid | default

apply with:
```
terraform apply -var="instance_uuid=4b7270ba-3cdc-4c59-bb70-3489d3027278"
```

**finalize_share_interface must be ran after this**


### attach_volume
this example requires 2 variables:
  - volume_id
  - instance_id

apply with:
```
terraform apply -var="instance_id=4b7270ba-3cdc-4c59-bb70-3489d3027278" -var="volume_id=81495916-d440-4663-8516-2470e8a61158"
```

### create_and_attach_volume
this example requires 3 variables:
  - volume_name
  - volume_size
  - instance_id

apply with:
```
terraform apply -var="instance_id=4b7270ba-3cdc-4c59-bb70-3489d3027278" -var="volume_name=test_disk_02" -var="volume_size=1"
```

### create_instance_from_existing_volume
this example requires 2 variables:
  - volume_id

apply with:
```
terraform apply -var="volume_id=4b7270ba-3cdc-4c59-bb70-3489d3027278"
```

### create_instance_from_new_volume
this example requires 4 variables:
  - volume_image
  - volume_name
  - volume_size
  - instance_name

apply with:
```
terraform apply -var="volume_image=4b7270ba-3cdc-4c59-bb70-3489d3027278" -var="volume_name=test_disk_02" -var="volume_size=20" -var="instance_name=test"
```

### create_share
this example requires 5 variables, 4 of which have defaults:
  - share_name (required)
  - share_description
  - share_protocol
  - share_type
  - share_size

it creates a typical manila NFS share per the beginning instructions [here](https://iujetstream.atlassian.net/wiki/spaces/JWT/pages/537231493/Using+Manila+-+Filesystems-as-a-service+-+on+Jetstream)

apply with:
```
terraform apply -var="share_name=test"
```

### create share rule
this example requires 2 variables:
  - instance_uuid
  - share_uuid

it uses the instance's uuid to obtain the manila nic's ip address.  this address and the share_uuid are used as part of the operation to create the rule.

apply with:
```
terraform apply -var="instance_uuid=ef62d33f-a53c-4a42-851f-63c4c8eb8410" -var="share_uuid=a8171b87-182d-4f31-b830-2b186f6043c9"
```

### create_volume
this example requires 2 variables:
  - volume_name
  - volume_size

apply with:
```
terraform apply -var="volume_name=test_disk_01" -var="volume_size=1"
```

### finalize_share_interface
**this is still a work in progress**
at the moment, this example requires 1 variable:
  - instance_uuid

the objective of this example is to follow the post interface attachment requirements documented [here](https://iujetstream.atlassian.net/wiki/spaces/JWT/pages/537231493/Using+Manila+-+Filesystems-as-a-service+-+on+Jetstream)

however, there is difficulty in calling ansible from terraform, specifically without defining a hosts.yml file.  this ansible requires as little as:
```
all:
  hosts:
    examplehost:
      ansible_user: ubuntu
      ansible_host: 149.165.171.159
```
