# Terraform JS2 Deployment instructions

Through a running bastion host, one can control (launch, shut down, restart) a number of VMs on the JS2 architecture.

*ssh (in terraform.tfvars) and ID/Secret (in openrc) values have been removed for safety reasons.*

:warning: **Note: If this is your first time doing this, please start from [Setting up your own Bastion host for OpenStack VMs Deployment: starting from stratch](#setting-up-your-own-bastion-host-for-openstack-vms-deployment-starting-from-stratch).

---

**Sections**:

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
3. [Accessing your deployed VMs](#accessing-your-deployed-vms)
---

## Setting up your own Bastion host for OpenStack VMs Deployment: starting from stratch 

### Getting the Bastion VM
⚠️**NOTE:** This guide assumes you have access to [JetStream2 (JS2) Horizon](https://js2.jetstream-cloud.org/auth/login/?next=/project/instances/) and have resources for your Project

1. In JS2 Horizon, create an `openrc` file by going to Application Credentials (in the left hand menu: Identity > Application Credentials > + Create Application Credential (on the right)). Download the generated file, rename it `openrc`.
2. Create a m3.tiny VM (under Source) with Launch Instance (this will function as your host). The minimum requirements are:
    - A name (Details > Instance Name)
    - Ubuntu 20 (Source)
    - Key Pair (required to add access the bastion VM). To crate a Key Pair:
        1. On your computer, generate an ssh key with `ssh-keygen -t rsa -b 4096`
        2. Copy the public key to Compute > Key Pairs > Import Public Key
        3. Under your Instances, associate a floating IP address under the Actions drop-down menu.
3. Copy `openrc` to your machine.
4. Do `source openrc` (suggested to add the source command to `bashrc`. **If you do not add `source openrc` to bashrc, then you will have to source every time you will connect to the VM.**)

### Setting up the prerequisites
⚠️**NOTE:** See [cacao terraform-openstack gitlab page](https://gitlab.com/cyverse/cacao-tf-os-ops/-/tree/main/) further instructions

From your Bastion, clone this repository:

```
$ git clone https://github.com/CosiMichele/tf-js2-template.git
```

Do the following commands in order to install the appropriate software:

```
# Export necessary versions
$ export TERRAFORM_VER=0.14.4  
$ export OPENSTACK_PROVIDER_VER=1.32.0

# Install necessary packages
$ sudo apt-get install -qq -y --no-install-recommends wget zip ansible curl unzip   

$ cd /tmp 

# Download and install Terraform
$ wget https://releases.hashicorp.com/terraform/${TERRAFORM_VER}/terraform_${TERRAFORM_VER}_linux_amd64.zip 
$ unzip terraform_${TERRAFORM_VER}_linux_amd64.zip  
$ chmod +x ./terraform 
$ sudo mv ./terraform /usr/bin

# Download and install OpenStack
$ wget https://github.com/terraform-provider-openstack/terraform-provider-openstack/releases/download/v${OPENSTACK_PROVIDER_VER}/terraform-provider-openstack_${OPENSTACK_PROVIDER_VER}_linux_amd64.zip 
$ unzip terraform-provider-openstack_${OPENSTACK_PROVIDER_VER}_linux_amd64.zip  # select Yes to if asked 
$ chmod +x terraform-provider-openstack_v${OPENSTACK_PROVIDER_VER}  
$ sudo mkdir -p /$USER/.terraform.d/plugins/terraform.cyverse.org/cyverse/openstack/${OPENSTACK_PROVIDER_VER}/linux_amd64 
$ sudo mv terraform-provider-openstack_v${OPENSTACK_PROVIDER_VER} /$USER/.terraform.d/plugins/terraform.cyverse.org/cyverse/openstack/${OPENSTACK_PROVIDER_VER}/linux_amd64/  

# Install Ansible related requirements
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
$ cd tf-js2-template/cacao-tf-os-ops/vms4workshop

# Copy terraform.tfvars.example and rename the copy terraform.tfvars
$ cp terraform.tfvars.example terraform.tfvars
```

Edit tfvars as necessary (below is an example with explainations)

```
# openstack info
project = "TG-CIS220026"                       # Name of your project on JS2
security_groups = ["default"]                  # Do not modify if no other security group was created
instance_name = "esiil"                        # What you want your VMs to be called
username = "cosi" 
image = "fb37f2eb-101c-46ee-8a7e-ac3e9b910671" # Image ID on JetStream, this is equivalent as the Ubuntu 20. You can find the ID by clicking on the arrow left of the Image name in the Images page.
flavor = "m3.tiny"                             # Size of VMs you want to deploy
keypair = "Bastion-2"                          # Add here the name of the keypair you created
ip_pool = "public"
user_data = ""
do_ansible_execution=true

# if there is shared storage, set to share_name to "" if none
share_name = ""
share_access_key=""
share_mount_path=""

# Note, you can change the power_state to "shutoff" to temporarily turn the instances off
power_state = "active"

# Total student 
instance_instructor_count = 1
student_usernames=["user1","user2","user3"]
students_per_instance=2
instructors_ssh_keys_base64=""                # Paste here the encoded SSH key you created
do_generate_local_csv=true
```

---

## Usage Instructions

The main configuration file will be `terraform.tfvars`. Unless you know what you're doing, only edit this file and rerun terraform plan/apply.

### Terraform

IMPORTANT: When using terraform be sure to execute `terraform` command within the directory containing the `terraform.tfvars` file i.e. `vms4workshop`.

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

## Accessing your deployed VMs

A CSV file will be generated in the folder where the user carried out the `terraform` commands. Below is an example:

```
user,password,instance_name,ip_address,local_vnc_port
instructor,xnqIQ$sensibly$easy$haddock,esiil-instructor,149.165.155.164,5906
user1,p2Gka$fully$mature$duckling,esiil-student0,149.165.152.63,5906
user2,Gx7OE$deeply$amazed$lamprey,esiil-student0,149.165.152.63,5907
user3,qqCVt$remotely$cosmic$sawfish,esiil-student1,149.165.154.6,5906
```

Each line after the header is the information for each single user. One connects to a VM by doing

```
$ ssh <user_number/instructor>@<IP>
```
Use the password generated when prompted.

Distribute the credentials from the CSV file as needed.