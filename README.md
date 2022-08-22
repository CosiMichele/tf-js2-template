# terraform-js2-deploy-template

See https://gitlab.com/cyverse/cacao-tf-os-ops

Through a running bastion host, one can control (launch, shut down, restart) a number of VMs on the JS2 architecture. Here are files used to deploy JS2 VMs through the CACAO bastion host used for the CompBio Asia 2022 workshop.

*ssh (in terraform.tfvars) and ID/Secret (in openrc) values have been removed for safety reasons.*

:warning **Note: If this is your first time doing this, please start from [Setting up your own Bastion host for OpenStack VMs Deployment: starting from stratch](#setting-up-your-own-bastion-host-for-openstack-vms-deployment-starting-from-stratch).

---

Jump to:

1. [Setting up your own Bastion host for OpenStack VMs Deployment: starting from stratch](#setting-up-your-own-bastion-host-for-openstack-vms-deployment-starting-from-stratch)
    1. [Getting the Bastion VM](#getting-the-bastion-vm)
    2. [Setting up the prerequisites](#setting-up-the-prerequisites)
    3. [Editing tfvars and deployment](#editing-tfvars-and-deployment)
2. [Usage Instructions](#usage-instructions)
    1. [Terraform](#terraform)
    2. [Creating resources](#creating-resources)
    3. [Stopping (and restarting) instances](#stopping-and-restarting-instances)
    4. [Verifying current terraform state](#verifying-current-terraform-state)
    5. [Destroying Resources](#destroying-resources)

---

## Setting up your own Bastion host for OpenStack VMs Deployment: starting from stratch 

### Getting the Bastion VM
⚠️**NOTE:** This guide assumes you have access to [JetStream2 (JS2) Horizon](https://js2.jetstream-cloud.org/auth/login/?next=/project/instances/) and have resources for your Project

1. In JS2 Horizon, create an `openrc` file by going to Application Credentials (in the left hand menu: Identity > Application Credentials > + Create Application Credential (on the right)). Download the generated file, rename it `openrc`.
2. Create a m3.tiny VM. This will function as your host. Copy `openrc` to your machine.
3. Do `source openrc` (suggested to add to `bashrc`)

### Setting up the prerequisites
⚠️**NOTE:** Follow the steps at the [cacao terraform-openstack gitlab page](https://gitlab.com/cyverse/cacao-tf-os-ops/-/tree/main/) for software pre-requirements

From your Bastion, do the following commands in order to install the appropriate software:
```
$ export TERRAFORM_VER=0.14.4  
$ export OPENSTACK_PROVIDER_VER=1.32.0  
$ sudo apt-get install -qq -y --no-install-recommends wget zip ansible curl unzip   
$ cd /tmp 
$ wget https://releases.hashicorp.com/terraform/${TERRAFORM_VER}/terraform_${TERRAFORM_VER}_linux_amd64.zip 
$ unzip terraform_${TERRAFORM_VER}_linux_amd64.zip  
$ chmod +x ./terraform 
$ sudo mv ./terraform /usr/bin 
$ wget https://github.com/terraform-provider-openstack/terraform-provider-openstack/releases/download/v${OPENSTACK_PROVIDER_VER}/terraform-provider-openstack_${OPENSTACK_PROVIDER_VER}_linux_amd64.zip 
$ unzip terraform-provider-openstack_${OPENSTACK_PROVIDER_VER}_linux_amd64.zip  # select Yes to if asked 
$ chmod +x terraform-provider-openstack_v${OPENSTACK_PROVIDER_VER}  
$ sudo mkdir -p /$USER/.terraform.d/plugins/terraform.cyverse.org/cyverse/openstack/${OPENSTACK_PROVIDER_VER}/linux_amd64 
$ sudo mv terraform-provider-openstack_v${OPENSTACK_PROVIDER_VER} /$USER/.terraform.d/plugins/terraform.cyverse.org/cyverse/openstack/${OPENSTACK_PROVIDER_VER}/linux_amd64/  
$ ansible-galaxy collection install ansible.posix 
```
Create an ssh key pair and copy the `.pub` (public) to horizon ((in the left hand menu: Compuyte > Key Pairs > Import Public Key (on the right)):
```
$ ssh-keygen -t rsa -b 4096 
```
Encode your key (necessary for instructor VMs); you will need to copy and paste this later.
```
$ openssl enc -base64 -in id_rsa.pub -out id_rsa_enc.pub  
```

### Editing tfvars and deployment

```
cd cacao-tf-os-ops/vm4workshop
```
Edit tfvars as necessary 

---

## Usage Instructions

### Files and Folders
The primary folder of interest is `/root/cacao-tf-os-ops`, which is a modified git clone of https://gitlab.com/cyverse/cacao-tf-os-ops, on branch `compbio2022-wheeler`. This will be merged into `main` branch shortly.

In `cacao-tf-os-ops`, there are 3 folders of interest:
* `create_share`: used to create the manila share
* `vms4workshop-genomics`: used to create the CPU instances
* `vms4workshop-md-screening`: used to create GPU instances

The main configuration file will be `terraform.tfvars`. Unless you know what you're doing, only edit this file and rerun terraform plan/apply.

### Terraform

IMPORTANT: When using terraform be sure to execute `terraform` command within the directory containing the `terraform.tfvars` file i.e. `vms4workshop-genomics` and `vms4workshop-md-screening` folders.

### Creating Resources
After editing the appropriate `terraform.tfvars` file using your favorite editor. You can run the following:

1. `terraform plan -out plan.out`
2. `terraform apply plan.out`

If you want an all-in-one command, just run `terraform plan -out plan.out && terraform apply plan.out`. Note, the reason why some folks will separate these steps out is just to review what changes will be made before committing to the changes in a `terraform plan` step.

### Stopping (and restarting) instances
Why stop instances? To conserve allocation without destroying them.

1. edit `terraform.tfvars` and set `power_state = "shutoff"`.
2. `terraform plan -out plan.out && terraform apply plan.out`

To restart, just set the `power_state = active` and reapply terraform.

### Verifying current terraform state

* `terraform show`: to verify if there are currently resources deployed with the template
* `terraform output`: to display any output variables, assuming there are currently resources deployed with the template

### Destroying Resources
Why destroy resources? Well, to ensure you don't waste allocation. Definitely destroy resources after the workshop has concluded. Use this command wisely.

`terraform destroy` (or `terraform destroy -auto-approve` to bypass the confirmation step)

---