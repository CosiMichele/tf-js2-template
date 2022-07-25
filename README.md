# terraform-js2-deploy-template

See https://gitlab.com/cyverse/cacao-tf-os-ops

Through a running bastion host, one can control (launch, shut down, restart) a number of VMs on the JS2 architecture. Here are files used to deploy JS2 VMs through the CACAO bastion host used for the CompBio Asia 2022 workshop.

*ssh (in terraform.tfvars) and ID/Secret (in openrc) values have been removed for safety reasons.*

## Quickstart

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